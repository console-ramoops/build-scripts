#!/bin/bash
source ~/.build_secrets
SECONDS=0
MID=""

esc() {
    echo "$1" | sed 's/[_*\[\]()~`>#+\-=|{}.!]/\\&/g'
}

send_msg() {
    local TEXT="$1"
    if [ -z "$MID" ]; then
        # Use --data-urlencode to correctly handle newlines for the Telegram API.
        RESP=$(curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
            -d chat_id=$TG_CID --data-urlencode "text=$TEXT" -d parse_mode="MarkdownV2")
        MID=$(echo "$RESP" | grep -o '"message_id":[0-9]*' | cut -d: -f2 | head -1)
    else
        # Also apply the fix here for editing messages.
        curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/editMessageText" \
            -d chat_id=$TG_CID -d message_id=$MID --data-urlencode "text=$TEXT" -d parse_mode="MarkdownV2" > /dev/null 2>&1
    fi
}

send_msg "🚀 *Build Started*"

. build/envsetup.sh

# Add error handling for the lunch command.
if ! lunch voltage_santoni-bp2a-user > /tmp/lunch.log 2>&1; then
    send_msg "❌ *Lunch Failed*"
    # Send the last 20 lines of the lunch log, which now contains the error.
    ERR=$(tail -20 /tmp/lunch.log 2>/dev/null | esc)
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id=$TG_CID -d text="\`\`\`$ERR\`\`\`" -d parse_mode="MarkdownV2" > /dev/null
    exit 1
fi


# Parse lunch output
DEV=$(grep "TARGET_PRODUCT=" /tmp/lunch.log | cut -d= -f2 | tr -d ' ')
VER=$(grep "PLATFORM_VERSION=" /tmp/lunch.log | cut -d= -f2 | tr -d ' ')

export BUILD_USERNAME=alpha269
export BUILD_HOSTNAME=crave
export KBUILD_BUILD_USER=alpha269
export KBUILD_BUILD_HOST=crave
export TZ=Asia/Kolkata

send_msg "🔨 *Building* $(esc "$DEV")
*Android:* $(esc "$VER")"

m bacon || m systemimage && m vendorimage || {
    send_msg "❌ *Build Failed*"
    ERR=$(tail -20 out/error.log 2>/dev/null | esc)
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id=$TG_CID -d text="\`\`\`$ERR\`\`\`" -d parse_mode="MarkdownV2" > /dev/null
    exit 1
}

ZIP=$(find out/target/product/$DEV -name "voltage*santoni*.zip" | head -1)

# Check if the ZIP file was actually found
if [ -z "$ZIP" ]; then
    send_msg "❌ *Build Succeeded, but ZIP not found!*"
    exit 1
fi

rsync -avP -e "ssh -i ~/.ssh/sourceforge_key -o StrictHostKeyChecking=no" \
    "$ZIP" "alpha269@frs.sourceforge.net:/home/frs/project/alpha-s-trashdump/AOSP/" > /dev/null 2>&1

FN=$(basename "$ZIP")
URL="https://downloads.sourceforge.net/project/alpha-s-trashdump/AOSP/$FN"
TIME=$(printf '%dh:%dm:%ds' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60)))

send_msg "✅ *Build Complete*
*Device:* $(esc "$DEV")
*Time:* $(esc "$TIME")
*Download:* $(esc "$URL")"


URL="https://downloads.sourceforge.net/project/alpha-s-trashdump/AOSP/$(basename "$ZIP")"
TIME=$(printf '%dh:%dm:%ds' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60)))

send_msg "✅ *Build Complete*\n*Device:* $TARGET_DEVICE\n*Time:* $TIME\n*Download:* \`$URL\`"
