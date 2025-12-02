echo "OpenGL backend to use:"
read -p "1)GLFW 2)SDL 3)RGFW 4)DRM/RPi 5)CPU/SOFTWARE: " PLAT
case "$PLAT" in
    [1]*)#GLFW
        FORM=Desktop
        sed -i 's/^TARGET_BACKEND=.*/TARGET_BACKEND=BACKEND_GLFW/' .scripts/config.sh
        ;;
    [2]*)#SDL
        FORM=SDL
        sed -i 's/^TARGET_BACKEND=.*/TARGET_BACKEND=BACKEND_SDL/' .scripts/config.sh
        ;;
    [3]*)#RGFW
        echo "RGFW support has been introduced a year and a half ago yet its still not exposed to CMake, might have to axe CMake and reconsider how i do things here if i continue"
        exit 1 ;;
#         FORM=RGFW
#         sed -i 's/^TARGET_BACKEND=.*/TARGET_BACKEND=BACKEND_RGFW/' .scripts/config.sh
#         ;;
    [4]*)#RPi
        FORM=DRM
        sed -i 's/^TARGET_BACKEND=.*/TARGET_BACKEND=BACKEND_DRM/' .scripts/config.sh
        ;;
    [5]*)#SOFTWARE, which only works through SDL and DRM atm
        FORM=SDL
        sed -i 's/^TARGET_BACKEND=.*/TARGET_BACKEND=BACKEND_SDL/' .scripts/config.sh
        BACKEND=Software
        ;;
    *) echo "invalid input"; exit 1 ;;
esac
if [ "$PLAT" != 5 ]; then
    echo "Force a specific OpenGL version? (UNTESTED but should work fine) :"
    read -p "1)No 2)1.1 3)2.1 4)3.3 5)4.3: " GL
    case "$GL" in
        [1]*) BACKEND=OFF;;
        [2]*) BACKEND=1.1;;
        [3]*) BACKEND=2.1;;
        [4]*) BACKEND=3.3;;
        [5]*) BACKEND=4.3;;
        *) echo "null input"; exit 1 ;;
    esac
fi
cd raylib
mkdir --parents build
cd build
cmake -DBUILD_SHARED_LIBS=OFF -DPLATFORM=$FORM -DOPENGL_VERSION=$BACKEND -DBUILD_EXAMPLES=OFF ..
make
mkdir --parents ../../platform/desktop/lib
mv raylib/libraylib.a ../../platform/desktop/lib
#might be a bad idea since it completely destroys what's in the directory
mkdir --parents ../../platform/desktop/include
mv raylib/include/* ../../platform/desktop/include

#Push Variables into config.sh so that when running it'll now how to compile
