FROM ubuntu:18.04
MAINTAINER Thomas P. <docker@legz.fr>


# ------------------------------------------------------
# --- Install required tools

RUN apt-get update -qq

# Base (non android specific) tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  wget \
  python \
  zip \
  unzip \
  imagemagick

# Dependencies to execute Android builds
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  openjdk-8-jdk 


# ------------------------------------------------------
# --- Download Android SDK tools

# Up to date link for SDK TOOLS: https://developer.android.com/studio/index.html#command-tools
ENV VERSION_SDK_TOOLS="4333796"
ENV ANDROID_HOME="/android-sdk"

# emulator is in its own path since 25.3.0 (not in sdk tools anymore)
ENV PATH=$PATH:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools 

# Install sdk tools
RUN wget -q -O android-sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip \
  && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
  && rm android-sdk-tools.zip

# Workaround for
# Warning: File /root/.android/repositories.cfg could not be loaded.
RUN mkdir /root/.android && touch /root/.android/repositories.cfg


# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK. You should only install the packages you need!
# To get a full list of available options you can use: sdkmanager --list

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN yes | sdkmanager --licenses

# Platform tools
RUN sdkmanager "emulator" "tools" "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

# Please keep all sections in descending order!
RUN yes | sdkmanager \
    "platforms;android-27" \
    "platform-tools" \
    "build-tools;27.0.3" \
    "system-images;android-27;google_apis;x86" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" 


# ------------------------------------------------------
# --- Install Fastlane

#RUN apt-get -y install ruby-dev
#RUN gem install fastlane --no-document \
#&& fastlane --version


# ------------------------------------------------------
# --- Cleanup

#RUN apt-get clean \
#  && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* 