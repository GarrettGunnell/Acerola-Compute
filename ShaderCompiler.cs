using Godot;
using Godot.Collections;
using System.Text.RegularExpressions;

[Tool]
public partial class ShaderCompiler : Node
{
    public static ShaderCompiler Instance { get; private set; }

    private readonly RenderingDevice m_rd;
    private readonly Array<string> m_computeShaderFilePaths = [];
    private readonly System.Collections.Generic.Dictionary<string, string> m_shaderCodeCache = [];
    private readonly System.Collections.Generic.Dictionary<string, Array<Rid>> m_computeShaderKernelCompilations = [];
    private readonly System.Collections.Generic.Dictionary<string, bool> m_shaderReady = [];

    /// <summary>
    /// Creates a shader compilation class for processing acompute shader files.
    /// </summary>
    public ShaderCompiler() : base()
    {
        Instance = this;
        this.m_rd = RenderingServer.GetRenderingDevice();
        this.FindFiles("res://");
        foreach (string filePath in this.m_computeShaderFilePaths) this.CompileComputeShader(filePath);
    }

    public override void _Process(double delta)
    {
        // Compare current shader code with cached shader code and recompile if changed
        foreach (string filePath in this.m_computeShaderFilePaths)
        {
            // Check if we need to update the cache
            if (this.m_shaderCodeCache[filePath] == LoadFromFile(filePath)) continue;

            string shaderName = GetShaderName(filePath);

            if (this.m_computeShaderKernelCompilations.TryGetValue(shaderName, out Array<Rid> kernelValues))
            {
                // Free existing kernels
                foreach (Rid kernel in kernelValues)
                {
                    if (!kernel.IsValid) continue;
                    this.m_rd.FreeRid(kernel);
                }

                this.m_shaderReady[shaderName] = false;
                this.m_computeShaderKernelCompilations[shaderName].Clear();
            }

            // Compute the shader again
            this.CompileComputeShader(filePath);
        }
    }

    public override void _Notification(int what)
    {
        if (what != NotificationPredelete && what != NotificationWMCloseRequest) return;

        foreach (string computeShader in this.m_computeShaderKernelCompilations.Keys)
        {
            foreach (Rid kernel in this.m_computeShaderKernelCompilations[computeShader])
            {
                if (!kernel.IsValid) continue;
                this.m_rd.FreeRid(kernel);
            }
        }

    }

    /// <summary>
    /// Returns the requested compute shader kernel or an empty <c>Rid</c>.
    /// </summary>
    /// <param name="shaderName"></param>
    /// <param name="kernelIndex"></param>
    /// <returns></returns>
    public Rid GetComputeKernelCompilation(string shaderName, int kernelIndex)
    {
        // Check we have the requested kernel
        if (!this.m_computeShaderKernelCompilations.TryGetValue(shaderName, out Array<Rid> kernels) || kernelIndex >= kernels.Count)
        {
            return new Rid();
        }

        return kernels[kernelIndex];
    }

    /// <summary>
    /// Returns a list of kernels or <c>null</c> if the shader does not exist.
    /// </summary>
    /// <param name="shaderName"></param>
    /// <returns></returns>
    public Array<Rid> GetComputeKernelCompilations(string shaderName)
    {
        if (!this.m_computeShaderKernelCompilations.TryGetValue(shaderName, out Array<Rid> kernels))
        {
            return null;
        }

        return kernels;
    }

    /// <summary>
    /// Returns <c>true</c> when the shader has been compiled successfully.
    /// </summary>
    /// <param name="shaderName"></param>
    /// <returns></returns>
    public bool GetShaderReady(string shaderName)
    {
        if (!this.m_shaderReady.TryGetValue(shaderName, out bool state))
        {
            return false;
        }

        return state;
    }

    /// <summary>
    /// Performs the shader compilation for the request acompute file.
    /// </summary>
    /// <param name="computeShaderFilePath"></param>
    private void CompileComputeShader(string computeShaderFilePath)
    {
        string computeShaderName = GetShaderName(computeShaderFilePath);
        this.m_shaderReady[computeShaderName] = false;
        GD.Print(string.Format("Compiling Compute Shader: {0}", computeShaderName));

        using FileAccess file = FileAccess.Open(computeShaderFilePath, FileAccess.ModeFlags.Read);

        if (file == null)
        {
            GD.PrintErr(string.Format("Unable to find shader file, {0}", computeShaderFilePath));
            return;
        }

        string rawShaderCodeString = file.GetAsText();

        // Store the code cache
        this.m_shaderCodeCache[computeShaderFilePath] = rawShaderCodeString;

        Array<string> kernelNames = [];
        Array<string> rawShaderCode = [.. rawShaderCodeString.Split("\n")];

        // Strip out kernel names
        while (file.GetPosition() < file.GetLength())
        {
            string line = file.GetLine();

            // Kernels must always come at the top of the file
            if (!line.StartsWith("#kernel ")) break;

            string kernelName = line.Split("#kernel")[1].StripEdges();
            kernelNames.Add(kernelName);
            rawShaderCode.RemoveAt(0);
        }

        // If no kernels defined at top of file, fail to compile
        if (kernelNames.Count == 0)
        {
            GD.PushError(string.Format("Failed to compile: {0}", computeShaderFilePath));
            GD.PushError("Reason: No kernels found");
            return;
        }

        // If no code after kernel definitions or if nothing in file at all, fail to compile
        if (file.GetPosition() >= file.GetLength())
        {
            GD.PushError(string.Format("Failed to compile: {0}", computeShaderFilePath));
            GD.PushError("Reason: No shader code found");
            return;
        }

        // Verify kernels exist
        rawShaderCodeString = string.Join('\n', rawShaderCode);
        foreach (string kernelName in kernelNames)
        {
            if (!MatchKernelName(rawShaderCodeString, kernelName))
            {
                GD.PushError(string.Format("Failed to compile: {0}", computeShaderFilePath));
                GD.PushError(string.Format("Reason: {0} kernel not found!", kernelName));
                return;
            }
        }

        System.Collections.Generic.Dictionary<string, Array<string>> kernelToThreadGroupCount = [];

        // Find kernels and extract thread groups
        for (int i = 0; i < rawShaderCode.Count; i++)
        {
            string line = rawShaderCode[i];

            foreach (string kernelName in kernelNames)
            {
                if (!line.Contains(kernelName) || !line.Contains("void")) continue;

                // Find thread group count by searching previous line of code from kernel function
                string newLine = rawShaderCode[i - 1].StripEdges();

                if (!newLine.Contains("numthreads"))
                {
                    GD.PushError(string.Format("Failed to compile: {0}", computeShaderFilePath));
                    GD.PushError("Reason: kernel thread group count not found");
                    return;
                }

                string[] threadGroups = newLine.Split('(')[^1].Split(')')[0].Split(',');
                if (threadGroups.Length != 3)
                {
                    GD.PushError(string.Format("Failed to compile: {0}", computeShaderFilePath));
                    GD.PushError("Reason: kernel thread group syntax error");
                    return;
                }

                kernelToThreadGroupCount[kernelName] = [];
                for (int j = 0; j < threadGroups.Length; j++) kernelToThreadGroupCount[kernelName].Add(threadGroups[j].StripEdges());
                rawShaderCode[i - 1] = "";
            }
        }

        // Compile kernels
        this.m_computeShaderKernelCompilations[computeShaderName] = [];

        foreach (string kernelName in kernelNames)
        {
            // Clone the array
            Array<string> shaderCode = [.. rawShaderCode];

            // Insert GLSL thread group layout for the kernel
            Array<string> threadGroup = kernelToThreadGroupCount[kernelName];
            shaderCode.Insert(0, string.Format("layout(local_size_x = {0}, local_size_y = {1}, local_size_z = {2}) in;", threadGroup[0], threadGroup[1], threadGroup[2]));
            shaderCode.Insert(0, "#version 450"); // Insert GLSL version at top of file

            // Replace kernel name with main
            string shaderCodeString = string.Join("\n", shaderCode).Replace(kernelName, "main");

            // Compile shader
            RDShaderSource shaderSource = new()
            {
                Language = RenderingDevice.ShaderLanguage.Glsl,
                SourceCompute = shaderCodeString
            };

            RDShaderSpirV shaderSpirV = this.m_rd.ShaderCompileSpirVFromSource(shaderSource);

            if (!string.IsNullOrEmpty(shaderSpirV.CompileErrorCompute))
            {
                GD.PushError(shaderSpirV.CompileErrorCompute);
                GD.PushError(string.Format("In: {0}", shaderCodeString));
                return;
            }

            GD.Print(string.Format("- Compiling Kernel: {0}", kernelName));
            Rid shaderCompilation = this.m_rd.ShaderCreateFromSpirV(shaderSpirV);

            if (!shaderCompilation.IsValid)
            {
                return;
            }

            this.m_computeShaderKernelCompilations[computeShaderName].Add(shaderCompilation);
        }

        this.m_shaderReady[computeShaderName] = true;
    }

    /// <summary>
    /// Search the given directory and sub directories for files with the acompute file extension.
    /// </summary>
    /// <param name="directoryName"></param>
    private void FindFiles(string directoryName)
    {
        using DirAccess directory = DirAccess.Open(directoryName);
        if (directory == null) return;

        directory.ListDirBegin();
        string fileName = directory.GetNext();

        while (!string.IsNullOrEmpty(fileName))
        {

            // Recursively search sub directories
            if (directory.CurrentIsDir())
            {
                this.FindFiles(directoryName + '/' + fileName);
            }
            else if (fileName.GetExtension() == "acompute")
            {
                this.m_computeShaderFilePaths.Add(directoryName + '/' + fileName);
            }

            fileName = directory.GetNext();
        }

        directory.ListDirEnd();
    }

    private static bool MatchKernelName(string input, string kernelName)
    {
        string pattern = $@"\bvoid\s+{kernelName}\s*\(";
        return Regex.IsMatch(input, pattern);
    }

    private static string GetShaderName(string filePath)
    {
        return filePath.GetFile().Split(".")[0];
    }

    private static string LoadFromFile(string filePath)
    {
        using var file = FileAccess.Open(filePath, FileAccess.ModeFlags.Read);
        if (file == null) return "";
        string content = file.GetAsText();
        return content;
    }
}
