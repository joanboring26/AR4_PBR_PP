using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(renderer: typeof(ToneMapping),
             PostProcessEvent.AfterStack,
             "Custom/ToneMapping")]
public sealed class ToneMappingSettings : PostProcessEffectSettings
{
    [Range(0.0f, 10.0f)]
    public FloatParameter ExposureR = new FloatParameter { value = 1.0f };
    [Range(0.0f, 10.0f)]
    public FloatParameter ExposureG = new FloatParameter { value = 1.0f };
    [Range(0.0f, 10.0f)]
    public FloatParameter ExposureB = new FloatParameter { value = 1.0f };
    [Range(0.0f, 10.0f)]
    public FloatParameter Gamma = new FloatParameter { value = 1.0f };


}


public class ToneMapping : PostProcessEffectRenderer<ToneMappingSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/ToneMapping"));

        sheet.properties.SetFloat("_ExposureR", settings.ExposureR);
        sheet.properties.SetFloat("_ExposureG", settings.ExposureG);
        sheet.properties.SetFloat("_ExposureB", settings.ExposureB);
        sheet.properties.SetFloat("_Gamma", settings.Gamma);



        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);//, sheet, 0);
    }
}
