using Godot;
using System.Runtime.InteropServices;

[GlobalClass]
[Tool]
public partial class ExposureShader : CompositorEffect
{

  [Export]
  private Vector4 m_exposure = new(2, 1, 1, 1);

  private Shader m_exposureShader;

  /// <summary>
  /// Example compositor effect using the C# shader wrapper.
  /// </summary>
  public ExposureShader() : base()
  {
    RenderingServer.CallOnRenderThread(Callable.From(() =>
    {

      // It is possible to just include a resource path to a glsl compute shader
      // this.m_exposureShader = new("res://exposure_example.glsl");
      // this.m_exposureShader = new("res://exposure_example.glsl", false);

      // Create a shader wrapper for a custom shader
      this.m_exposureShader = new("exposure_example", true);
    }));
  }

  public override void _RenderCallback(int effectCallbackType, RenderData renderData)
  {
    if (!this.Enabled) return;
    if (effectCallbackType != (int)EffectCallbackTypeEnum.PostTransparent) return;

    RenderSceneBuffersRD renderSceneBuffers = (RenderSceneBuffersRD)renderData.GetRenderSceneBuffers();

    Vector2I size = renderSceneBuffers.GetInternalSize();
    if (size.X == 0 && size.Y == 0)
    {
      GD.PushError("Rendering to 0x0 buffer");
      return;
    }

    int xGroups = (size.X - 1) / 8 + 1;
    int yGroups = (size.Y - 1) / 8 + 1;
    int zGroups = 1;

    byte[] pushConstant = MemoryMarshal.AsBytes([size.X, size.Y, 0.0f, 0.0f]).ToArray();
    byte[] uniformArray = MemoryMarshal.AsBytes([this.m_exposure.X, this.m_exposure.Y, this.m_exposure.Z, this.m_exposure.W]).ToArray();

    Rid inputImage = renderSceneBuffers.GetColorLayer(0);

    this.m_exposureShader.SetPushConstant(ref pushConstant);
    this.m_exposureShader.SetTexture(0, inputImage);
    this.m_exposureShader.SetUniformBuffer(1, ref uniformArray);
    this.m_exposureShader.Dispatch(xGroups, yGroups, zGroups);
  }

  public override void _Notification(int what)
  {
    if (what == NotificationPredelete)
    {
      this.m_exposureShader.Free();
    }
  }

}
