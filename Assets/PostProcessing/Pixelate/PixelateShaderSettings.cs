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
    [Range(1.0f, 50.0f)]
    public FloatParameter Pixel_SizeX = new FloatParameter { value = 1.0f };
    [Range(1.0f, 50.0f)]
    public FloatParameter Pixel_SizeY = new FloatParameter { value = 1.0f };

    public IntParameter ResolutionX = new IntParameter { value = 1920 };
    public IntParameter ResolutionY = new IntParameter { value = 1080 };


}


public class PixelateShader : PostProcessEffectRenderer<PixelateShaderSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/PixelateShader"));

        sheet.properties.SetFloat("_pixelSizeX", settings.Pixel_SizeX);
        sheet.properties.SetFloat("_pixelSizeY", settings.Pixel_SizeY);
        sheet.properties.SetFloat("_resolutionX", settings.ResolutionX);
        sheet.properties.SetFloat("_resolutionY", settings.ResolutionY);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);//, sheet, 0);
    }
}

