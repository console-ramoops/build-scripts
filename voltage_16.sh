#!/bin/bash
source ~/.build_secrets
SECONDS=0

send_msg() {
    if [ -z "$MID" ]; then
        RESP=$(curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
            -d chat_id=$TG_CID -d text="$1" -d parse_mode="MarkdownV2")
        MID=$(echo "$RESP" | grep -o '"message_id":[0-9]*' | cut -d: -f2 | head -1)
    else
        curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/editMessageText" \
            -d chat_id=$TG_CID -d message_id=$MID -d text="$1" -d parse_mode="MarkdownV2" > /dev/null 2>&1
    fi
}

send_msg "🚀 *Build Started*"

. build/envsetup.sh
lunch voltage_santoni-bp2a-user

export BUILD_USERNAME=alpha269
export BUILD_HOSTNAME=crave
export KBUILD_BUILD_USER=alpha269
export KBUILD_BUILD_HOST=crave
export TZ=Asia/Kolkata

send_msg "🔨 *Building* $TARGET_DEVICE\n*Android:* $PLATFORM_VERSION"

m bacon || m systemimage && m vendorimage || {
    send_msg "❌ *Build Failed*"
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id=$TG_CID -d text="\`\`\`$(tail -20 out/error.log 2>/dev/null)\`\`\`" -d parse_mode="MarkdownV2"
    exit 1
}

ZIP=$(find out/target/product/$TARGET_DEVICE -name "voltage*santoni*zip" | head -1)
rsync -avP -e "ssh -i ~/.ssh/sourceforge_key -o StrictHostKeyChecking=no" \
    "$ZIP" "alpha269@frs.sourceforge.net:/home/frs/project/alpha-s-trashdump/AOSP/"

URL="https://downloads.sourceforge.net/project/alpha-s-trashdump/AOSP/$(basename "$ZIP")"
TIME=$(printf '%dh:%dm:%ds' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60)))

send_msg "✅ *Build Complete*\n*Device:* $TARGET_DEVICE\n*Time:* $TIME\n*Download:* \`$URL\`"
