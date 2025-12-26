#!/bin/bash
# Docker Image Shamer - Because your image is a disgrace to containers everywhere

# Check if Docker is installed (it probably is, but you never know with you people)
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not found. Can't shame what doesn't exist. Like your DevOps skills."
    exit 1
fi

# Check if image name was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <docker-image-name>"
    echo "Example: $0 my-app:latest  # Prepare for humiliation"
    exit 1
fi

IMAGE_NAME=$1

# Try to pull the image first (because you probably didn't build it locally)
echo "🔍 Inspecting $IMAGE_NAME... (please contain your shame)"

# Get image size in human-readable format
SIZE=$(docker image inspect $IMAGE_NAME --format='{{.Size}}' 2>/dev/null | \
       numfmt --to=iec --suffix=B 2>/dev/null || echo "N/A")

# Get number of layers (more layers = more shame)
LAYERS=$(docker image inspect $IMAGE_NAME --format='{{.RootFS.Layers}}' 2>/dev/null | \
         tr -d '[]' | wc -w 2>/dev/null || echo "N/A")

# Get base image (the foundation of your poor choices)
BASE=$(docker image inspect $IMAGE_NAME --format='{{.Config.Image}}' 2>/dev/null || echo "N/A")

# Get exposed ports (because you probably exposed everything)
PORTS=$(docker image inspect $IMAGE_NAME --format='{{json .Config.ExposedPorts}}' 2>/dev/null | \
        jq -r 'keys_unsorted | join(", ")' 2>/dev/null || echo "N/A")

# Shame calculation algorithm (patent pending)
SHAME_LEVEL=0

if [[ $SIZE != "N/A" ]]; then
    # Convert size to bytes for comparison
    SIZE_BYTES=$(echo $SIZE | sed 's/[A-Za-z]*$//')
    SIZE_UNIT=$(echo $SIZE | sed 's/[0-9.]*//')
    
    case $SIZE_UNIT in
        "MB")
            if (( $(echo "$SIZE_BYTES > 500" | bc -l 2>/dev/null || echo 0) )); then
                SHAME_LEVEL=$((SHAME_LEVEL + 1))
            fi
            ;;
        "GB")
            SHAME_LEVEL=$((SHAME_LEVEL + 2))
            ;;  # GB images get extra shame
    esac
fi

if [[ $LAYERS != "N/A" ]] && [ $LAYERS -gt 10 ]; then
    SHAME_LEVEL=$((SHAME_LEVEL + 1))
fi

if [[ $BASE == *"alpine"* ]]; then
    SHAME_LEVEL=$((SHAME_LEVEL - 1))  # Alpine users get a pass
fi

# Deliver the verdict
echo "\n📊 SHAME REPORT for $IMAGE_NAME:"
echo "   Size: $SIZE (${SHAME_LEVEL}/3 shame points for this alone)"
echo "   Layers: $LAYERS (each one a poor life choice)"
echo "   Base: $BASE (the apple doesn't fall far from the tree)"
echo "   Ports: $PORTS (hope you like security vulnerabilities)"
echo ""

# Final judgment
if [ $SHAME_LEVEL -ge 2 ]; then
    echo "💀 SHAME LEVEL: CRITICAL"
    echo "   Your Docker image is an embarrassment to the container community."
    echo "   Consider: multi-stage builds, smaller base images, or a career change."
elif [ $SHAME_LEVEL -eq 1 ]; then
    echo "⚠️  SHAME LEVEL: MODERATE"
    echo "   Your image could use some work. Like your commit messages."
else
    echo "✅ SHAME LEVEL: ACCEPTABLE"
    echo "   Not terrible. But we're still judging you silently."
fi

echo ""
