Android emulator Docker image with predownloaded jpeg file to test app interaction with photos.

You can change link to desired jpeg file [here](https://github.com/artemlushin/android-emulator/blob/5f367f9bb9f986d5427a0150b8f9f29eefbca355/entrypoint.sh#L29) or just remove lines 17-43 if you don't need jpeg file inside emulator.

[Here](https://github.com/artemlushin/android-emulator/blob/5f367f9bb9f986d5427a0150b8f9f29eefbca355/Dockerfile#L38) you can change desired platform and android image.

Also you can change device language, contry, locale and timezone [here](https://github.com/artemlushin/android-emulator/blob/5f367f9bb9f986d5427a0150b8f9f29eefbca355/entrypoint.sh#L15), or remove these arguments if you want default behaviour.

## build
docker build -t android-emulator .

## run
docker run --name emulator --privileged --device /dev/kvm -p 5554:5554 -p 5555:5555 android-emulator

## connect
adb connect localhost:5555
