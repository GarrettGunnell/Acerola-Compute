using Godot;
using Godot.Collections;
using System.Diagnostics;
using System.Linq;

public class Shader
{
    private readonly string m_shaderName;
    private readonly bool m_isCustom;
    private readonly RenderingDevice m_rd;
    private readonly Rid m_pipeline;
    private readonly System.Collections.Generic.Dictionary<int, byte[]> m_uniformBufferCache = []; // Contains the contents of the uniform array itself
    private readonly System.Collections.Generic.Dictionary<int, Rid> m_uniformBufferIdCache = []; // Contains the RIDs for the gpu versions of the uniform array
    private readonly Array<RDUniform> m_uniformSetCache = [];
    private readonly Array<Rid> m_kernels = [];

    private Rid m_shader;
    private Rid m_uniformSetGpuId;
    private byte[] m_pushConstant;
    private bool m_refreshUniforms = true;

    /// <summary>
    /// Creates a new shader wrapper. <para />
    /// 
    /// The <c>shaderName</c> can be one of two options. 
    /// <list type="number">
    ///     <item>The path to a shader resources i.e. "res://example.glsl"</item>
    ///     <item>The name of a custom acompute shader i.e. "example"</item>
    /// </list>
    /// When <c>isCustom</c> is false, the class expects that the shaderName will be a resource path.
    /// When <c>isCustom</c> is true, the class expects the shaderName will be a custom shader name.
    /// 
    /// </summary>
    /// <param name="shaderName"></param>
    /// <param name="isCustom"></param>
    public Shader(string shaderName, bool isCustom = false)
    {
        this.m_isCustom = isCustom;
        this.m_shaderName = shaderName;
        this.m_rd = RenderingServer.GetRenderingDevice();

        if (isCustom)
        {
            // Wait for our singleton to be created.
            // This appears to be a race condition between the render thread and something else.
            if (ShaderCompiler.Instance == null) return;

            this.m_shader = ShaderCompiler.Instance.GetComputeKernelCompilation(shaderName, 0);
            Debug.Assert(this.m_shader.IsValid, string.Format("Unable to find the requested shader: {0}", shaderName));

            if (!this.m_shader.IsValid)
            {
                return;
            }

            foreach (Rid kernel in ShaderCompiler.Instance.GetComputeKernelCompilations(shaderName))
            {
                this.m_kernels.Add(this.m_rd.ComputePipelineCreate(kernel));
            }
        }
        else
        {
            RDShaderFile shaderFile = GD.Load<RDShaderFile>(shaderName);
            Debug.Assert(shaderFile != null, "Unable to load the shader. Make sure you provided the right path.");
            RDShaderSpirV shaderSpirV = shaderFile.GetSpirV();
            this.m_shader = this.m_rd.ShaderCreateFromSpirV(shaderSpirV);
            this.m_pipeline = this.m_rd.ComputePipelineCreate(this.m_shader);
        }
    }

    /// <summary>
    /// Sets the shaders push constant byte array.
    /// </summary>
    /// <param name="pushConstant"></param>
    public void SetPushConstant(ref byte[] pushConstant)
    {
        this.m_pushConstant = pushConstant;
    }

    /// <summary>
    /// Sets a texture resource bound to the provided binding. The binding value must match the value in the shader file.
    /// </summary>
    /// <param name="binding"></param>
    /// <param name="texture"></param>
    public void SetTexture(int binding, Rid texture)
    {
        RDUniform textureUniform = new()
        {
            UniformType = RenderingDevice.UniformType.Image,
            Binding = binding
        };
        textureUniform.AddId(texture);
        this.CacheUniform(textureUniform);
    }

    /// <summary>
    /// Set a uniform buffer resource bound to the provided binding. The binding value must match the value in the shader file.
    /// </summary>
    /// <param name="binding"></param>
    /// <param name="uniformArray"></param>
    public void SetUniformBuffer(int binding, ref byte[] uniformArray)
    {
        // Check if buffer exists
        if (this.m_uniformBufferCache.TryGetValue(binding, out byte[] cacheValue))
        {
            // If buffer is identical, no need to change
            if (uniformArray.SequenceEqual(cacheValue)) return;

            // If new values but same buffer size, update gpu buffer
            if (uniformArray.Length == cacheValue.Length)
            {
                this.m_rd.BufferUpdate(this.m_uniformBufferIdCache[binding], 0, (uint)uniformArray.Length, uniformArray);
                this.m_uniformBufferCache[binding] = uniformArray;
                return;
            }

            // Otherwise, free the memory because footprint no longer matches
            this.m_rd.FreeRid(m_uniformBufferIdCache[binding]);
        }

        Rid uniformBufferId = this.m_rd.UniformBufferCreate((uint)uniformArray.Length, uniformArray);

        RDUniform u = new()
        {
            UniformType = RenderingDevice.UniformType.UniformBuffer,
            Binding = binding
        };
        u.AddId(uniformBufferId);

        // Cache array contents and RID
        this.m_uniformBufferCache[binding] = uniformArray;
        this.m_uniformBufferIdCache[binding] = uniformBufferId;

        this.CacheUniform(u);
    }

    /// <summary>
    /// Sets the compute shader to run. When running a custom shader, it is possible to specify a different kernel index to change which sub shader is run.
    /// </summary>
    /// <param name="xGroups"></param>
    /// <param name="yGroups"></param>
    /// <param name="zGroups"></param>
    /// <param name="kernelIndex"></param>
    public void Dispatch(int xGroups, int yGroups, int zGroups, int kernelIndex = 0)
    {
        if (this.m_isCustom)
        {
            this.DispatchCustom(xGroups, yGroups, zGroups, kernelIndex);
        }
        else
        {
            this.DispatchNormal(xGroups, yGroups, zGroups);
        }
    }

    /// <summary>
    /// Runs a normal compute shader.
    /// </summary>
    /// <param name="xGroups"></param>
    /// <param name="yGroups"></param>
    /// <param name="zGroups"></param>
    private void DispatchNormal(int xGroups, int yGroups, int zGroups)
    {
        // Reallocate GPU memory if uniforms need updating
        if (this.m_refreshUniforms)
        {
            if (this.m_uniformSetGpuId.IsValid) this.m_rd.FreeRid(this.m_uniformSetGpuId);
            this.m_uniformSetGpuId = this.m_rd.UniformSetCreate(this.m_uniformSetCache, this.m_shader, 0);
            this.m_refreshUniforms = false;
        }

        long compute_list = this.m_rd.ComputeListBegin();
        this.m_rd.ComputeListBindComputePipeline(compute_list, this.m_pipeline);
        this.m_rd.ComputeListBindUniformSet(compute_list, this.m_uniformSetGpuId, 0);
        this.m_rd.ComputeListSetPushConstant(compute_list, this.m_pushConstant, (uint)this.m_pushConstant.Length);
        this.m_rd.ComputeListDispatch(compute_list, (uint)xGroups, (uint)yGroups, (uint)zGroups);
        this.m_rd.ComputeListEnd();
    }

    /// <summary>
    /// Runs a custom compute shader.
    /// </summary>
    /// <param name="xGroups"></param>
    /// <param name="yGroups"></param>
    /// <param name="zGroups"></param>
    private void DispatchCustom(int xGroups, int yGroups, int zGroups, int kernelIndex)
    {
        // The shader is not ready to be used.
        if (!ShaderCompiler.Instance.GetShaderReady(this.m_shaderName)) return;

        Rid globalShaderId = ShaderCompiler.Instance.GetComputeKernelCompilation(this.m_shaderName, 0);

        // Recreate kernel pipelines if shader was recompiled
        if (this.m_shader != globalShaderId)
        {
            this.m_shader = globalShaderId;
            this.m_uniformSetGpuId = this.m_rd.UniformSetCreate(this.m_uniformSetCache, globalShaderId, 0);
            this.m_kernels.Clear();

            foreach (Rid kernel in ShaderCompiler.Instance.GetComputeKernelCompilations(this.m_shaderName))
            {
                this.m_kernels.Add(this.m_rd.ComputePipelineCreate(kernel));
            }
        }

        // Reallocate GPU memory if uniforms need updating
        if (this.m_refreshUniforms)
        {
            if (this.m_uniformSetGpuId.IsValid) this.m_rd.FreeRid(this.m_uniformSetGpuId);
            this.m_uniformSetGpuId = this.m_rd.UniformSetCreate(this.m_uniformSetCache, globalShaderId, 0);
            this.m_refreshUniforms = false;
        }

        long compute_list = this.m_rd.ComputeListBegin();
        this.m_rd.ComputeListBindComputePipeline(compute_list, this.m_kernels[kernelIndex]);
        this.m_rd.ComputeListBindUniformSet(compute_list, this.m_uniformSetGpuId, 0);
        this.m_rd.ComputeListSetPushConstant(compute_list, this.m_pushConstant, (uint)this.m_pushConstant.Length);
        this.m_rd.ComputeListDispatch(compute_list, (uint)xGroups, (uint)yGroups, (uint)zGroups);
        this.m_rd.ComputeListEnd();
    }

    /// <summary>
    /// Frees the shader resources.
    /// </summary>
    public void Free()
    {
        foreach (Rid kernel in this.m_kernels)
        {
            if (kernel.IsValid) this.m_rd.FreeRid(kernel);
        }

        foreach (Rid binding in this.m_uniformBufferIdCache.Values)
        {
            if (binding.IsValid) this.m_rd.FreeRid(binding);
        }

        if (this.m_uniformSetGpuId.IsValid) this.m_rd.FreeRid(this.m_uniformSetGpuId);
    }

    /// <summary>
    /// Caches the provided uniform resource. If this uniform is new or updates an existing uniform,
    /// the shader will recompute all requires sets on the next run.
    /// </summary>
    /// <param name="newUniform">The new uniform resource</param>
    private void CacheUniform(RDUniform newUniform)
    {
        int uniformIndex = newUniform.Binding;

        // Check to see if this uniform is new or replacing an old uniform
        if (uniformIndex >= this.m_uniformSetCache.Count)
        {
            this.m_refreshUniforms = true;
            this.m_uniformSetCache.Resize(uniformIndex + 1);
        }

        // If uniform has had its info changed then set flag to refresh gpu side uniform data
        if (this.m_uniformSetCache[uniformIndex] != null)
        {
            Array<Rid> oldUniformIds = this.m_uniformSetCache[uniformIndex].GetIds();
            Array<Rid> newUniformIds = newUniform.GetIds();

            if (oldUniformIds.Count != newUniformIds.Count)
            {
                this.m_refreshUniforms = true;
            }
            else
            {
                for (int i = 0; i < oldUniformIds.Count; i++)
                {
                    if (oldUniformIds[i].Id != newUniformIds[i].Id)
                    {
                        this.m_refreshUniforms = true;
                        break;
                    }
                }
            }
        }

        this.m_uniformSetCache[uniformIndex] = newUniform;
    }

}
