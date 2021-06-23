using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(renderer: typeof(VignetteShader),
             PostProcessEvent.AfterStack,
             "Custom/VignetteShader")]
public sealed class VignetteShaderSettings : PostProcessEffectSettings
{
    [Range(0.0f, 1.0f)]
    public FloatParameter lensRadius = new FloatParameter { value = 0.5f };
    public FloatParameter lensFeathering = new FloatParameter { value = 0.5f };
    public FloatParameter positionX = new FloatParameter { value = 0.5f };
    public FloatParameter positionY = new FloatParameter { value = 0.5f };
    [Range(-1.0f, 1.0f)]
    public FloatParameter deformationX = new FloatParameter { value = 0.0f };
    public FloatParameter deformationY = new FloatParameter { value = 0.0f };
    [Range(1.0f, 10.0f)]
    public FloatParameter lensSquaring = new FloatParameter { value = 0.0f };

    //public Texture2D tex = new Texture2D { value = "white"{ } };

}


public class VignetteShader : PostProcessEffectRenderer<VignetteShaderSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/VignetteShader"));

        sheet.properties.SetFloat("_lens_radius", settings.lensRadius);
        sheet.properties.SetFloat("_lens_squaring", settings.lensSquaring);
        sheet.properties.SetFloat("_lens_feathering", settings.lensFeathering);
        sheet.properties.SetFloat("_PositionX", settings.positionX);
        sheet.properties.SetFloat("_PositionY", settings.positionY);
        sheet.properties.SetFloat("deformation_X", settings.deformationX);
        sheet.properties.SetFloat("deformation_Y", settings.deformationY);


        context.command.BlitFullscreenTriangle(context.source, context.destination,sheet,0);//, sheet, 0);
    }
}
