# Wan2GP Model Mapping Guide

## Overview

This document shows how your existing models from `/mnt/llm/hub` map to the expected Wan2GP model files. The linking script `link_wan_models.sh` automatically creates symbolic links based on these mappings.

## Found Models in Your Database

### ✅ Wan 2.1 Models (Available)

| Expected Wan2GP File | Your Model File | Status |
|---------------------|-----------------|--------|
| `wan2.1_text2video_14B_quanto_mbf16_int8.safetensors` | `wan2.1_text2video_14B_quanto_mbf16_int8.safetensors` | ✅ FOUND |
| `wan2.1_image2video_480p_14B_quanto_mbf16_int8.safetensors` | `wan2.1_image2video_720p_14B_quanto_mbf16_int8.safetensors` | ✅ FOUND (720p→480p mapping) |
| `Wan2.1_VAE.safetensors` | `Wan2.1_VAE.safetensors` | ✅ FOUND |

### ✅ Wan 2.2 Models (Available)

| Expected Wan2GP File | Your Model File | Status |
|---------------------|-----------------|--------|
| `wan2.2_text2video_5B_mbf16.safetensors` | `wan2.2_ti2v_5B_fp16.safetensors` | ✅ FOUND |
| `Wan2.2_VAE.safetensors` | `wan2.2_vae.safetensors` | ✅ FOUND |
| `wan2.2_image2video_14B_high_q6k.gguf` | `Wan2.2-I2V-A14B-HighNoise-Q6_K.gguf` | ✅ FOUND (GGUF format) |
| `wan2.2_image2video_14B_low_q6k.gguf` | `Wan2.2-I2V-A14B-LowNoise-Q6_K.gguf` | ✅ FOUND (GGUF format) |

### ✅ Text Encoders (Available)

| Expected Wan2GP File | Your Model File | Status |
|---------------------|-----------------|--------|
| `umt5-xxl/models_t5_umt5-xxl-enc-bf16.safetensors` | `umt5-xxl-enc-bf16.safetensors` | ✅ FOUND |
| `xlm-roberta-large/models_clip_open-clip-xlm-roberta-large-vit-huge-14-bf16.safetensors` | `models_clip_open-clip-xlm-roberta-large-vit-huge-14-bf16.safetensors` | ✅ FOUND |
| `T5_xxl_1.1/T5_xxl_1.1_enc_quanto_bf16_int8.safetensors` | `T5_xxl_1.1_enc_quanto_bf16_int8.safetensors` | ✅ FOUND |

### ✅ Specialty Models (Available)

| Expected Wan2GP File | Your Model File | Status |
|---------------------|-----------------|--------|
| `wan2.1_Vace_14B_module_mbf16.safetensors` | `wan2.1_vace_14B_fp16.safetensors` | ✅ FOUND |
| `wan2.1_fantasy_speaking_14B_bf16.safetensors` | Various fantasy models available | ✅ FOUND |
| `wan2.1_multitalk_14B_mbf16.safetensors` | Various multitalk models available | ✅ FOUND |

### ❌ Missing Models (Expected by Wan2GP but not found)

| Expected Wan2GP File | Status | Notes |
|---------------------|--------|-------|
| `wan2.1_text2video_14B_mbf16.safetensors` | ❌ NOT FOUND | You have quantized version instead |
| `wan2.1_text2video_14B_high_mbf16.safetensors` | ❌ NOT FOUND | Wan 2.2 high noise model |
| `wan2.1_text2video_14B_low_mbf16.safetensors` | ❌ NOT FOUND | Wan 2.2 low noise model |
| `wan2.2_image2video_14B_high_mbf16.safetensors` | ❌ NOT FOUND | You have GGUF version instead |
| `wan2.2_image2video_14B_low_mbf16.safetensors` | ❌ NOT FOUND | You have GGUF version instead |

## Additional Models Available

You have many more Wan models that aren't used by the default Wan2GP configuration:

### Alternative Formats
- **GGUF Models**: You have several GGUF quantized versions that are more memory-efficient
- **FP8 Models**: Various FP8 quantized models for better performance
- **Specialized Variants**: AccVideo, CausVid, FusionX, etc.

### LoRA Models
- **182 Wan LoRA models** for customization
- **47 Wan Video LoRA models** for video-specific effects
- Covers various styles, poses, effects, and enhancements

## Usage Instructions

1. **Run the linking script**:
   ```bash
   ./link_wan_models.sh
   ```

2. **Check the results**:
   - Green checkmarks (✅) indicate successful links
   - Red X marks (❌) indicate missing models
   - Check `missing_models.txt` for commented placeholders

3. **Start Wan2GP**:
   ```bash
   ./run-offline.sh
   ```

4. **Model availability**:
   - Linked models will work immediately without downloads
   - Missing models will be auto-downloaded when first used
   - GGUF models may require different configuration

## Notes

- **File Formats**: Your models include safetensors, GGUF, and FP8 variants
- **Memory Usage**: GGUF and quantized models use less VRAM
- **Performance**: FP8 models may offer better speed/memory tradeoffs
- **Compatibility**: Most models should work with Wan2GP's auto-detection

## Troubleshooting

If models don't load:
1. Check the symbolic links: `ls -la Wan2GP/ckpts/`
2. Verify source files exist: `ls -la /mnt/llm/hub/models/[hash]/`
3. Check Wan2GP logs for specific model loading errors
4. Consider using quantized versions for lower VRAM systems