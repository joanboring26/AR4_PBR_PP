using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(renderer: typeof(PixelateShader),
             PostProcessEvent.AfterStack,
             "Custom/PixelateShader")]
public sealed class PixelateShaderSettings : PostProcessEffectSettings
{
    [Range(0.0f, 100.0f)]
    public FloatParameter Pixel_Size = new FloatParameter { value = 1.0f };


}


public class PixelateShader : PostProcessEffectRenderer<PixelateShaderSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/PixelateShader"));

        sheet.properties.SetFloat("_Pixel_Size", settings.Pixel_Size);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);//, sheet, 0);
    }
}

