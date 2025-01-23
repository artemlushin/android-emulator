# Start from a basic Debian or Ubuntu image
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    wget \
    unzip \
    libgl1-mesa-glx \
    libpulse0 \
    libx11-6 \
    libxcursor1 \
    libnss3 \
    libxcomposite1 \
    libasound2 \
    libc6 \
    libstdc++6 \
    socat \
	dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Download and install Android SDK command-line tools
RUN mkdir -p /android/sdk/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O /android/cmdline-tools.zip && \
    unzip /android/cmdline-tools.zip -d /android/sdk/cmdline-tools && \
    rm /android/cmdline-tools.zip && \
    mv /android/sdk/cmdline-tools/cmdline-tools /android/sdk/cmdline-tools/latest

# Set environment variables
ENV ANDROID_SDK_ROOT=/android/sdk
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools"

# Accept licenses and install platform tools
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses || true

# Install required packages
RUN $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" "platforms;android-34" "emulator" "system-images;android-34;google_apis;x86_64"

# Create Android AVD
RUN echo "no" | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/avdmanager create avd -n Pixel -k "system-images;android-34;google_apis;x86_64" --device "pixel"

# Expose necessary ports for adb and emulator connection
EXPOSE 5037 5554 5555

# Add a script to run socat for port forwarding and start adb and emulator
COPY entrypoint.sh /

# Convert entrypoint.sh to Unix format
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

# Use the script as the entrypoint
ENTRYPOINT ["sh", "/entrypoint.sh"]
