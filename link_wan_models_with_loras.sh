#!/bin/bash
# Wan2GP Model + LoRA Linking Script
# Generated from existing model database at /mnt/llm/hub/hub.db
# Maps your existing models AND LoRAs to expected Wan2GP locations

set -e

HUB_DB="/mnt/llm/hub/hub.db"
MODELS_DIR="/mnt/llm/hub/models"
WAN_CKPTS_DIR="./Wan2GP/ckpts"
WAN_LORAS_DIR="./Wan2GP/loras"
WAN_LORAS_I2V_DIR="./Wan2GP/loras_i2v"
WAN_LORAS_HUNYUAN_DIR="./Wan2GP/loras_hunyuan"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
            echo -e "${YELLOW}🔄 Replacing existing symlink: $(basename "$target")${NC}"
            rm "$target"
        else
            echo -e "${YELLOW}⚠️  Backing up existing file: $(basename "$target") -> $(basename "$target").backup${NC}"
            mv "$target" "$target.backup"
        fi
    fi
    
    # Create the symbolic link
    ln -sf "$source" "$target"
    echo -e "${GREEN}✅ Linked: $description${NC}"
    echo -e "   ${BLUE}$(basename "$target") -> $(basename "$source")${NC}"
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

# Function to link LoRAs by base model type
link_loras_by_type() {
    local base_model="$1"
    local target_dir="$2"
    local description="$3"
    
    echo -e "${PURPLE}🎨 Linking $description LoRAs...${NC}"
    
    # Get all LoRAs for this base model
    sqlite3 "$HUB_DB" "SELECT filename, file_hash FROM models WHERE deleted = FALSE AND base_model = '$base_model' AND model_type = 'lora' ORDER BY filename;" 2>/dev/null | while IFS='|' read -r filename hash; do
        if [[ -n "$filename" && -n "$hash" ]]; then
            source_path="$MODELS_DIR/$hash/$filename"
            target_path="$target_dir/$filename"
            
            if [[ -f "$source_path" ]]; then
                create_link "$source_path" "$target_path" "$description LoRA: $(basename "$filename" .safetensors)"
            fi
        fi
    done
}

echo -e "${BLUE}🚀 Starting Wan2GP Model + LoRA Linking Process...${NC}"
echo -e "${BLUE}Database: $HUB_DB${NC}"
echo -e "${BLUE}Models Dir: $MODELS_DIR${NC}"
echo -e "${BLUE}Target Dirs: $WAN_CKPTS_DIR, $WAN_LORAS_DIR, etc.${NC}"
echo ""

# Clear missing models file
> missing_models.txt

# Create necessary directories
echo -e "${BLUE}📁 Creating directory structure...${NC}"
mkdir -p "$WAN_CKPTS_DIR"/{depth,flow,mask,pose,scribble,wav2vec,umt5-xxl,xlm-roberta-large,llava-llama-3-8b,clip_vit_large_patch14,whisper-tiny,det_align,T5_xxl_1.1,mmaudio}
mkdir -p "$WAN_LORAS_DIR" "$WAN_LORAS_I2V_DIR" "$WAN_LORAS_HUNYUAN_DIR"
mkdir -p "./Wan2GP/loras_flux" "./Wan2GP/loras_ltxv" "./Wan2GP/loras_qwen"

echo ""
echo -e "${BLUE}🔗 Creating symbolic links for existing models...${NC}"
echo ""

# =============================================================================
# MAIN WAN 2.1 MODELS (same as before)
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

# =============================================================================
# LORA MODELS - NEW SECTION!
# =============================================================================

echo ""
echo -e "${PURPLE}🎨 ═══════════════════════════════════════${NC}"
echo -e "${PURPLE}🎨 LINKING LORA MODELS${NC}"
echo -e "${PURPLE}🎨 ═══════════════════════════════════════${NC}"

# Link Wan LoRAs (base_model = "wan")
wan_lora_count=$(sqlite3 "$HUB_DB" "SELECT COUNT(*) FROM models WHERE deleted = FALSE AND base_model = 'wan' AND model_type = 'lora';" 2>/dev/null)
echo -e "${PURPLE}📊 Found $wan_lora_count Wan LoRAs in database${NC}"
link_loras_by_type "wan" "$WAN_LORAS_DIR" "Wan"

# Link Wan Video LoRAs (base_model = "wan video")  
wan_video_lora_count=$(sqlite3 "$HUB_DB" "SELECT COUNT(*) FROM models WHERE deleted = FALSE AND base_model = 'wan video' AND model_type = 'lora';" 2>/dev/null)
echo -e "${PURPLE}📊 Found $wan_video_lora_count Wan Video LoRAs in database${NC}"
link_loras_by_type "wan video" "$WAN_LORAS_I2V_DIR" "Wan Video"

# Link Wan Video 14B I2V LoRAs
wan_video_14b_lora_count=$(sqlite3 "$HUB_DB" "SELECT COUNT(*) FROM models WHERE deleted = FALSE AND base_model = 'wan video 14b i2v 720p' AND model_type = 'lora';" 2>/dev/null)
echo -e "${PURPLE}📊 Found $wan_video_14b_lora_count Wan Video 14B I2V LoRAs in database${NC}"
link_loras_by_type "wan video 14b i2v 720p" "$WAN_LORAS_I2V_DIR" "Wan Video 14B I2V"

# Link Hunyuan LoRAs
hunyuan_lora_count=$(sqlite3 "$HUB_DB" "SELECT COUNT(*) FROM models WHERE deleted = FALSE AND base_model = 'hunyuan' AND model_type = 'lora';" 2>/dev/null)
echo -e "${PURPLE}📊 Found $hunyuan_lora_count Hunyuan LoRAs in database${NC}"
link_loras_by_type "hunyuan" "$WAN_LORAS_HUNYUAN_DIR" "Hunyuan"

# Link any other LoRAs we might have missed
echo ""
echo -e "${PURPLE}🔍 Checking for other LoRA types...${NC}"
sqlite3 "$HUB_DB" "SELECT DISTINCT base_model, COUNT(*) FROM models WHERE deleted = FALSE AND model_type = 'lora' AND base_model NOT IN ('wan', 'wan video', 'wan video 14b i2v 720p', 'hunyuan') GROUP BY base_model ORDER BY COUNT(*) DESC;" 2>/dev/null | while IFS='|' read -r base_model count; do
    if [[ -n "$base_model" && "$count" -gt 0 ]]; then
        echo -e "${PURPLE}📊 Found $count LoRAs for base_model: '$base_model'${NC}"
        
        # Map to appropriate directory based on model type
        case "$base_model" in
            *flux*|*"flux"*)
                target_dir="./Wan2GP/loras_flux"
                ;;
            *ltx*|*"ltxv"*)
                target_dir="./Wan2GP/loras_ltxv"
                ;;
            *qwen*)
                target_dir="./Wan2GP/loras_qwen"
                ;;
            *)
                target_dir="$WAN_LORAS_DIR"  # Default to main loras directory
                ;;
        esac
        
        link_loras_by_type "$base_model" "$target_dir" "$base_model"
    fi
done

echo ""
echo -e "${BLUE}📋 SUMMARY${NC}"

# Count total LoRAs linked
total_loras_linked=$(find ./Wan2GP/loras* -name "*.safetensors" -type l 2>/dev/null | wc -l)
echo -e "${GREEN}✅ Models and LoRAs linked successfully!${NC}"
echo -e "${PURPLE}🎨 Total LoRAs linked: $total_loras_linked${NC}"

if [[ -s missing_models.txt ]]; then
    echo -e "${YELLOW}⚠️  Some models were not found. Check missing_models.txt for details.${NC}"
    echo -e "${YELLOW}📄 Missing models list saved to: missing_models.txt${NC}"
else
    echo -e "${GREEN}🎉 All expected models were found and linked!${NC}"
fi

echo ""
echo -e "${BLUE}📊 LoRA Distribution:${NC}"
for lora_dir in ./Wan2GP/loras*; do
    if [[ -d "$lora_dir" ]]; then
        count=$(find "$lora_dir" -name "*.safetensors" -type l 2>/dev/null | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "${PURPLE}   $(basename "$lora_dir"): $count LoRAs${NC}"
        fi
    fi
done

echo ""
echo -e "${BLUE}🔧 To use this setup:${NC}"
echo "   1. Review the created links in: $WAN_CKPTS_DIR and ./Wan2GP/loras*"
echo "   2. Start your Wan2GP Docker containers"
echo "   3. Models and LoRAs will be available without additional downloads"
echo "   4. Use LoRAs in the Wan2GP interface for custom effects and styles"
echo ""
echo -e "${GREEN}✨ Model + LoRA linking complete!${NC}"