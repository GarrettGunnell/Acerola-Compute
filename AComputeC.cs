using System.Diagnostics;
using Godot;

public partial class AComputeC
{
    private readonly GodotObject m_AComputeShader;

    /// <summary>
    /// Create an ACompute shader wrapper for use within C# scripts.
    /// </summary>
    /// <param name="shaderName"></param>
    /// <param name="aComputePath"></param>
    public AComputeC(string shaderName, string aComputePath = "res://acompute.gd")
    {
        GDScript shaderResource = GD.Load<GDScript>(aComputePath);
        Debug.Assert(shaderResource != null, "Make sure the aComputePath points to the location of the acompute.gd script.");
        
        // Create the acompute.gd node
        this.m_AComputeShader = (GodotObject)shaderResource.New(shaderName);
    }

    /// <summary>
    /// Gets the Rid for the kernel at the specified index.
    /// </summary>
    /// <param name="index"></param>
    /// <returns></returns>
    public Rid GetKernel(int index)
    {
        return (Rid)m_AComputeShader.Call("get_kernel", index);
    }

    /// <summary>
    /// Set the shader push constant byte array.
    /// </summary>
    /// <param name="pushConstants"></param>
    public void SetPushConstant(ref byte[] pushConstants)
    {
        m_AComputeShader.Call("set_push_constant", pushConstants);
    }

    /// <summary>
    /// Set a texture resource bound to the binding. The binding value must match the value in the shader file.
    /// </summary>
    /// <param name="binding"></param>
    /// <param name="texture"></param>
    public void SetTexture(int binding, Rid texture)
    {
        m_AComputeShader.Call("set_texture", binding, texture);
    }

    /// <summary>
    /// Set a uniform buffer resource bound to the binding. The binding value must match the value in the shader file.
    /// </summary>
    /// <param name="binding"></param>
    /// <param name="uniformArray"></param>
    public void SetUniformBuffer(int binding, ref byte[] uniformArray)
    {
        m_AComputeShader.Call("set_uniform_buffer", binding, uniformArray);
    }

    /// <summary>
    /// Set the compute shader to run.
    /// </summary>
    /// <param name="xGroups"></param>
    /// <param name="yGroups"></param>
    /// <param name="zGroups"></param>
    /// <param name="kernelIndex"></param>
    public void Dispatch(int kernelIndex, int xGroups, int yGroups, int zGroups)
    {
        m_AComputeShader.Call("dispatch", kernelIndex, xGroups, yGroups, zGroups);
    }

    /// <summary>
    /// Free the shader resources.
    /// </summary>
    public void Free()
    {
        m_AComputeShader.Call("free");
    }
}
using System.Diagnostics;
using Godot;

public partial class AComputeC
{
    private readonly GodotObject m_AComputeShader;

    /// <summary>
    /// Create an ACompute shader wrapper for use within C# scripts.
    /// </summary>
    /// <param name="shaderName"></param>
    /// <param name="aComputePath"></param>
    public AComputeC(string shaderName, string aComputePath = "res://acompute.gd")
    {
        GDScript shaderResource = GD.Load<GDScript>(aComputePath);
        Debug.Assert(shaderResource != null, "Make sure the aComputePath points to the location of the acompute.gd script.");
        
        // Create the acompute.gd node
        this.m_AComputeShader = (GodotObject)shaderResource.New(shaderName);
    }

    /// <summary>
    /// Gets the Rid for the kernel at the specified index.
    /// </summary>
    /// <param name="index"></param>
    /// <returns></returns>
    public Rid GetKernel(int index)
    {
        return (Rid)m_AComputeShader.Call("get_kernel", index);
    }

    /// <summary>
    /// Set the shader push constant byte array.
    /// </summary>
    /// <param name="pushConstants"></param>
    public void SetPushConstant(ref byte[] pushConstants)
    {
        m_AComputeShader.Call("set_push_constant", pushConstants);
    }

    /// <summary>
    /// Set a texture resource bound to the binding. The binding value must match the value in the shader file.
    /// </summary>
    /// <param name="binding"></param>
    /// <param name="texture"></param>
    public void SetTexture(int binding, Rid texture)
    {
        m_AComputeShader.Call("set_texture", binding, texture);
    }

    /// <summary>
    /// Set a uniform buffer resource bound to the binding. The binding value must match the value in the shader file.
    /// </summary>
    /// <param name="binding"></param>
    /// <param name="uniformArray"></param>
    public void SetUniformBuffer(int binding, ref byte[] uniformArray)
    {
        m_AComputeShader.Call("set_uniform_buffer", binding, uniformArray);
    }

    /// <summary>
    /// Set the compute shader to run.
    /// </summary>
    /// <param name="xGroups"></param>
    /// <param name="yGroups"></param>
    /// <param name="zGroups"></param>
    /// <param name="kernelIndex"></param>
    public void Dispatch(int kernelIndex, int xGroups, int yGroups, int zGroups)
    {
        m_AComputeShader.Call("dispatch", kernelIndex, xGroups, yGroups, zGroups);
    }

    /// <summary>
    /// Free the shader resources.
    /// </summary>
    public void Free()
    {
        m_AComputeShader.Call("free");
    }
}
