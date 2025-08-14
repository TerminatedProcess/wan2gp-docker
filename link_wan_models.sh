#!/bin/bash
# Wan2GP Model Linking Script
# Generated from existing model database at /mnt/llm/hub/hub.db
# Maps your existing models to expected Wan2GP locations

set -e

HUB_DB="/mnt/llm/hub/hub.db"
MODELS_DIR="/mnt/llm/hub/models"
WAN_CKPTS_DIR="./Wan2GP/ckpts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to create symbolic link with safety checks
create_link() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    if [[ ! -f "$source" ]]; then
        echo -e "${RED}❌ Source not found: $source${NC}"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target")
    mkdir -p "$target_dir"
    
    # Remove existing file/link if it exists
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            echo -e "${YELLOW}🔄 Replacing existing symlink: $target${NC}"
            rm "$target"
        else
            echo -e "${YELLOW}⚠️  Backing up existing file: $target -> $target.backup${NC}"
            mv "$target" "$target.backup"
        fi
    fi
    
    # Create the symbolic link
    ln -sf "$source" "$target"
    echo -e "${GREEN}✅ Linked: $description${NC}"
    echo -e "   ${BLUE}$target -> $source${NC}"
}

# Function to find model by filename pattern
find_model() {
    local pattern="$1"
    sqlite3 "$HUB_DB" "SELECT file_hash FROM models WHERE deleted = FALSE AND filename LIKE '%$pattern%' LIMIT 1;" 2>/dev/null
}

# Function to create commented placeholder
create_placeholder() {
    local target="$1"
    local description="$2"
    echo -e "${RED}❌ NOT FOUND: $description${NC}"
    echo "# ln -sf /path/to/model $target  # NOT FOUND: $description" >> missing_models.txt
}

echo -e "${BLUE}🚀 Starting Wan2GP Model Linking Process...${NC}"
echo -e "${BLUE}Database: $HUB_DB${NC}"
echo -e "${BLUE}Models Dir: $MODELS_DIR${NC}"
echo -e "${BLUE}Target Dir: $WAN_CKPTS_DIR${NC}"
echo ""

# Clear missing models file
> missing_models.txt

# Create necessary directories
echo -e "${BLUE}📁 Creating directory structure...${NC}"
mkdir -p "$WAN_CKPTS_DIR"/{depth,flow,mask,pose,scribble,wav2vec,umt5-xxl,xlm-roberta-large,llava-llama-3-8b,clip_vit_large_patch14,whisper-tiny,det_align,T5_xxl_1.1,mmaudio}

echo ""
echo -e "${BLUE}🔗 Creating symbolic links for existing models...${NC}"
echo ""

# =============================================================================
# MAIN WAN 2.1 MODELS
# =============================================================================

echo -e "${YELLOW}📦 WAN 2.1 TEXT-TO-VIDEO MODELS${NC}"

# Wan2.1 Text2Video 14B variants
hash=$(find_model "wan2.1_text2video_14B_quanto_mbf16_int8.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/wan2.1_text2video_14B_quanto_mbf16_int8.safetensors" \
                "$WAN_CKPTS_DIR/wan2.1_text2video_14B_quanto_mbf16_int8.safetensors" \
                "Wan2.1 Text2Video 14B (quantized int8)"
else
    create_placeholder "$WAN_CKPTS_DIR/wan2.1_text2video_14B_mbf16.safetensors" "Wan2.1 Text2Video 14B"
fi

# Try alternative naming patterns
hash=$(find_model "Wan2_1-T2V-14B_fp8_e5m2.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/Wan2_1-T2V-14B_fp8_e5m2.safetensors" \
                "$WAN_CKPTS_DIR/wan2.1_text2video_14B_fp8_e5m2.safetensors" \
                "Wan2.1 Text2Video 14B (fp8_e5m2)"
fi

echo ""
echo -e "${YELLOW}📦 WAN 2.1 IMAGE-TO-VIDEO MODELS${NC}"

# Wan2.1 Image2Video variants
hash=$(find_model "wan2.1_image2video_720p_14B_quanto_mbf16_int8.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/wan2.1_image2video_720p_14B_quanto_mbf16_int8.safetensors" \
                "$WAN_CKPTS_DIR/wan2.1_image2video_480p_14B_quanto_mbf16_int8.safetensors" \
                "Wan2.1 Image2Video 14B 720p (mapped to 480p)"
else
    create_placeholder "$WAN_CKPTS_DIR/wan2.1_image2video_480p_14B_mbf16.safetensors" "Wan2.1 Image2Video 14B"
fi

echo ""
echo -e "${YELLOW}📦 WAN 2.2 MODELS${NC}"

# Wan2.2 TextImage2Video 5B
hash=$(find_model "wan2.2_ti2v_5B_fp16.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/wan2.2_ti2v_5B_fp16.safetensors" \
                "$WAN_CKPTS_DIR/wan2.2_text2video_5B_mbf16.safetensors" \
                "Wan2.2 TextImage2Video 5B"
else
    create_placeholder "$WAN_CKPTS_DIR/wan2.2_text2video_5B_mbf16.safetensors" "Wan2.2 TextImage2Video 5B"
fi

# Try to find Wan2.2 high/low noise models from GGUF files
hash=$(find_model "Wan2.2-I2V-A14B-HighNoise-Q6_K.gguf")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/Wan2.2-I2V-A14B-HighNoise-Q6_K.gguf" \
                "$WAN_CKPTS_DIR/wan2.2_image2video_14B_high_q6k.gguf" \
                "Wan2.2 I2V 14B High Noise (GGUF)"
fi

hash=$(find_model "Wan2.2-I2V-A14B-LowNoise-Q6_K.gguf")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/Wan2.2-I2V-A14B-LowNoise-Q6_K.gguf" \
                "$WAN_CKPTS_DIR/wan2.2_image2video_14B_low_q6k.gguf" \
                "Wan2.2 I2V 14B Low Noise (GGUF)"
fi

echo ""
echo -e "${YELLOW}📦 VAE MODELS${NC}"

# Wan2.1 VAE
hash=$(find_model "Wan2.1_VAE.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/Wan2.1_VAE.safetensors" \
                "$WAN_CKPTS_DIR/Wan2.1_VAE.safetensors" \
                "Wan2.1 VAE"
else
    create_placeholder "$WAN_CKPTS_DIR/Wan2.1_VAE.safetensors" "Wan2.1 VAE"
fi

# Wan2.2 VAE
hash=$(find_model "wan2.2_vae.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/wan2.2_vae.safetensors" \
                "$WAN_CKPTS_DIR/Wan2.2_VAE.safetensors" \
                "Wan2.2 VAE"
else
    create_placeholder "$WAN_CKPTS_DIR/Wan2.2_VAE.safetensors" "Wan2.2 VAE"
fi

echo ""
echo -e "${YELLOW}📦 TEXT ENCODERS${NC}"

# T5 Text Encoder
hash=$(find_model "umt5-xxl-enc-bf16.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/umt5-xxl-enc-bf16.safetensors" \
                "$WAN_CKPTS_DIR/umt5-xxl/models_t5_umt5-xxl-enc-bf16.safetensors" \
                "UMT5-XXL Text Encoder"
else
    create_placeholder "$WAN_CKPTS_DIR/umt5-xxl/models_t5_umt5-xxl-enc-bf16.safetensors" "UMT5-XXL Text Encoder"
fi

# CLIP Text Encoder
hash=$(find_model "models_clip_open-clip-xlm-roberta-large-vit-huge-14-bf16.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/models_clip_open-clip-xlm-roberta-large-vit-huge-14-bf16.safetensors" \
                "$WAN_CKPTS_DIR/xlm-roberta-large/models_clip_open-clip-xlm-roberta-large-vit-huge-14-bf16.safetensors" \
                "XLM-RoBERTa CLIP Text Encoder"
else
    create_placeholder "$WAN_CKPTS_DIR/xlm-roberta-large/models_clip_open-clip-xlm-roberta-large-vit-huge-14-bf16.safetensors" "XLM-RoBERTa CLIP Text Encoder"
fi

# T5 XXL 1.1 for LTX Video
hash=$(find_model "T5_xxl_1.1_enc_quanto_bf16_int8.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/T5_xxl_1.1_enc_quanto_bf16_int8.safetensors" \
                "$WAN_CKPTS_DIR/T5_xxl_1.1/T5_xxl_1.1_enc_quanto_bf16_int8.safetensors" \
                "T5 XXL 1.1 Text Encoder (quantized)"
else
    create_placeholder "$WAN_CKPTS_DIR/T5_xxl_1.1/T5_xxl_1.1_enc_bf16.safetensors" "T5 XXL 1.1 Text Encoder"
fi

echo ""
echo -e "${YELLOW}📦 SPECIALTY MODELS${NC}"

# VACE modules
hash=$(find_model "wan2.1_vace_14B_fp16.safetensors")
if [[ -n "$hash" ]]; then
    create_link "$MODELS_DIR/$hash/wan2.1_vace_14B_fp16.safetensors" \
                "$WAN_CKPTS_DIR/wan2.1_Vace_14B_module_mbf16.safetensors" \
                "Wan2.1 VACE 14B Module"
else
    create_placeholder "$WAN_CKPTS_DIR/wan2.1_Vace_14B_module_mbf16.safetensors" "Wan2.1 VACE 14B Module"
fi

# Fantasy speaking model
hash=$(sqlite3 "$HUB_DB" "SELECT file_hash FROM models WHERE deleted = FALSE AND filename LIKE '%fantasy%' AND filename LIKE '%14B%' LIMIT 1;" 2>/dev/null)
if [[ -n "$hash" ]]; then
    filename=$(sqlite3 "$HUB_DB" "SELECT filename FROM models WHERE deleted = FALSE AND file_hash = '$hash' LIMIT 1;" 2>/dev/null)
    create_link "$MODELS_DIR/$hash/$filename" \
                "$WAN_CKPTS_DIR/wan2.1_fantasy_speaking_14B_bf16.safetensors" \
                "Wan2.1 Fantasy Speaking 14B"
else
    create_placeholder "$WAN_CKPTS_DIR/wan2.1_fantasy_speaking_14B_bf16.safetensors" "Wan2.1 Fantasy Speaking 14B"
fi

# Multitalk model
hash=$(sqlite3 "$HUB_DB" "SELECT file_hash FROM models WHERE deleted = FALSE AND filename LIKE '%multitalk%' AND filename LIKE '%14B%' LIMIT 1;" 2>/dev/null)
if [[ -n "$hash" ]]; then
    filename=$(sqlite3 "$HUB_DB" "SELECT filename FROM models WHERE deleted = FALSE AND file_hash = '$hash' LIMIT 1;" 2>/dev/null)
    create_link "$MODELS_DIR/$hash/$filename" \
                "$WAN_CKPTS_DIR/wan2.1_multitalk_14B_mbf16.safetensors" \
                "Wan2.1 Multitalk 14B"
else
    create_placeholder "$WAN_CKPTS_DIR/wan2.1_multitalk_14B_mbf16.safetensors" "Wan2.1 Multitalk 14B"
fi

echo ""
echo -e "${BLUE}📋 SUMMARY${NC}"
echo -e "${GREEN}✅ Symbolic links created successfully!${NC}"

if [[ -s missing_models.txt ]]; then
    echo -e "${YELLOW}⚠️  Some models were not found. Check missing_models.txt for details.${NC}"
    echo -e "${YELLOW}📄 Missing models list saved to: missing_models.txt${NC}"
else
    echo -e "${GREEN}🎉 All expected models were found and linked!${NC}"
fi

echo ""
echo -e "${BLUE}🔧 To use this setup:${NC}"
echo "   1. Review the created links in: $WAN_CKPTS_DIR"
echo "   2. Start your Wan2GP Docker containers"
echo "   3. Models will be available without additional downloads"
echo ""
echo -e "${GREEN}✨ Model linking complete!${NC}"