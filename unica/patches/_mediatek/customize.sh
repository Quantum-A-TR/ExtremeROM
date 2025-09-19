    ADD_JAR_TO_CLASSPATH()
{
    _CHECK_NON_EMPTY_PARAM "FILE" "$1"
    _CHECK_NON_EMPTY_PARAM "SCOPE" "$2"
    _CHECK_NON_EMPTY_PARAM "JAR_PATH" "$3"

    local FILE="$1"
    local SCOPE="$2"
    local JAR_PATH="$3"
    local MIN_API="$4"
    local MAX_API="$5"
    local PROTO="$SRC_DIR/unica/patches/_mediatek/classpaths.proto"

    if [[ "$FILE" == "bootclasspath" ]]; then
        FILE="$WORK_DIR/system/system/etc/classpaths/bootclasspath.pb"
    elif [[ "$FILE" == "systemserverclasspath" ]]; then
        FILE="$WORK_DIR/system/system/etc/classpaths/systemserverclasspath.pb"
    fi

    if [ ! -f "$FILE" ]; then
        _ECHO_STDERR ERR "File not found: ${FILE//$WORK_DIR/}"
        return 1
    fi

    if [[ "$SCOPE" != "UNKNOWN" ]] && [[ "$SCOPE" != "BOOTCLASSPATH" ]] && [[ "$SCOPE" != "SYSTEMSERVERCLASSPATH" ]] && \
      [[ "$SCOPE" != "DEX2OATBOOTCLASSPATH" ]] && [[ "$SCOPE" != "STANDALONE_SYSTEMSERVER_JARS" ]]; then
        _ECHO_STDERR ERR "\"$SCOPE\" is not a valid scope."
        return 1
    fi

    # Decode given binary file to text
    PDR="$(pwd)"
    cd "$(dirname "$FILE")"
    protoc --decode=ExportedClasspathsJars --proto_path="$(dirname "$PROTO")" "$(basename "$PROTO")" < "$(basename "$FILE")" > "$(basename "$FILE").txt"

    # Add to the text file
    echo "jars {" >> "$(basename "$FILE").txt"
    echo "  path: \"$JAR_PATH\"" >> "$(basename "$FILE").txt"
    echo "  classpath: $SCOPE" >> "$(basename "$FILE").txt"
    if [ -n "$MIN_API" ]; then
        echo "  min_sdk_version: \"$MIN_API\"" >> "$(basename "$FILE").txt"
    fi
    if [ -n "$MAX_API" ]; then
        echo "  max_sdk_version: \"$MAX_API\"" >> "$(basename "$FILE").txt"
    fi
    echo "}" >> "$(basename "$FILE").txt"

    # Encode back text file to binary
    protoc --encode=ExportedClasspathsJars --proto_path="$(dirname "$PROTO")" "$(basename "$PROTO")" < "$(basename "$FILE").txt" > "$(basename "$FILE")"
    rm "$(basename "$FILE").txt"
    cd "$PDR"
}

if [[ $TARGET_SINGLE_SYSTEM_IMAGE == "mssi" || $TARGET_SINGLE_SYSTEM_IMAGE == "mssi_64" ]]; then
    echo "Mediatek target device detected! Patching..."

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "product" "etc/permissions/product-permissions-mediatek.xml"

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/apex/com.android.btservices.apex"

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/privapp-permissions-mediatek.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/verizon_net_sip_library.xml"
    DELETE_FROM_WORK_DIR "system" "system/etc/permissions/vexfwk_service_lib.xml"
    DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.android.app.vex.scanner.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/ams_aal_config.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/audio_effects.conf"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/msync_ctrl_table.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/open_msync_app_list.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/public.libraries-mtk.txt"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/public.libraries-trustonic.txt"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/resolution_tuner_app_list.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/public.libraries-camera.samsung.txt"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/public.libraries-arcsoft.txt"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/TelephonyLog_dynamic.ds"
    DELETE_FROM_WORK_DIR "system" "system/etc/public.libraries-vexfwk.samsung.txt"

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/framework/verizon.net.sip.jar"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/framework/msync-lib.jar"
    DELETE_FROM_WORK_DIR "system" "system/framework/vexfwk_service_lib.jar"

# Disabled this for now because idk how to use prebuilts :/
#    ADD_TO_WORK_DIR "gts10pxxx" "system" "system/lib64/libLttEngine.camera.samsung.so"
#    ADD_TO_WORK_DIR "gts10pxxx" "system" "system/lib64/libDocShadowRemoval.arcsoft.so"
#    {
#        echo "libLttEngine.camera.samsung.so"
#    } >> "$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt"

    DELETE_FROM_WORK_DIR "system" "system/priv-app/VexScanner"
    DELETE_FROM_WORK_DIR "system" "system/priv-app/vexfwk_service"

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "app/MDMLSample/MDMLSample.apk"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "app/mediatek-res/mediatek-res.apk"


    DELETE_FROM_WORK_DIR "system_ext" "bin"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "bin"

    DELETE_FROM_WORK_DIR "system_ext" "lib"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "lib"

    DELETE_FROM_WORK_DIR "system_ext" "lib64"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "lib64"

    DELETE_FROM_WORK_DIR "system_ext" "usp"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "usp"

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "framework/mediatek-ims-base.jar"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "framework/mediatek-framework.jar"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "framework/mediatek-common.jar"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "framework/log-handler.jar"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "framework/duraspeed.jar"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "framework/DataChannelApi.jar"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "framework/CustomPropInterface.jar"

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "priv-app/ApmService/ApmService.apk"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_engine_configuration.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/hearing_aid_audio_policy_configuration.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/nr-city.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/custom.conf"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/r_submix_audio_policy_configuration.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/aee-config"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_volumes.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/bluetooth_audio_policy_configuration.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/usb_audio_policy_configuration.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_engine_product_strategies.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/a2dp_audio_policy_configuration.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_engine_default_stream_volumes.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/mtklog-config.prop"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/default_volume_tables.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/spn-conf.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/aee-commit"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_configuration_stub.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_configuration_bluetooth_legacy_hal.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_engine_stream_volumes.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/a2dp_in_audio_policy_configuration.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/audio_policy_configuration.xml"

    DELETE_FROM_WORK_DIR "system_ext" "etc/init"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/init"

    DELETE_FROM_WORK_DIR "system_ext" "etc/selinux"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/selinux"

    DELETE_FROM_WORK_DIR "odm" "etc/selinux"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "odm" "etc/selinux"

    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/permissions/system-ext-permissions-mediatek.xml"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system_ext" "etc/sysconfig/com.mediatek.ims.config.xml"

    ADD_JAR_TO_CLASSPATH "bootclasspath" "BOOTCLASSPATH" "/system_ext/framework/mediatek-common.jar"
    ADD_JAR_TO_CLASSPATH "bootclasspath" "DEX2OATBOOTCLASSPATH" "/system_ext/framework/mediatek-common.jar"
    ADD_JAR_TO_CLASSPATH "bootclasspath" "BOOTCLASSPATH" "/system_ext/framework/mediatek-framework.jar"
    ADD_JAR_TO_CLASSPATH "bootclasspath" "DEX2OATBOOTCLASSPATH" "/system_ext/framework/mediatek-framework.jar"
    ADD_JAR_TO_CLASSPATH "bootclasspath" "BOOTCLASSPATH" "/system_ext/framework/mediatek-ims-base.jar"
    ADD_JAR_TO_CLASSPATH "bootclasspath" "DEX2OATBOOTCLASSPATH" "/system_ext/framework/mediatek-ims-base.jar"

    SET_METADATA "system" "system/framework/framework-res.apk" 0 0 644 "u:object_r:system_mtk_pmb_file:s0"

    # Set MSSI Props
    SET_PROP "system" "ro.build.product" "mssi"
    SET_PROP "system" "ro.product.system.device" "mssi"
    SET_PROP "system_ext" "ro.product.system_ext.device" "mssi"
    SET_PROP "product" "ro.product.product.device" "mssi"

    #Add Mediatek Props
    SET_PROP "system" "Build.BRAND" "MTK"
    SET_PROP "system" "debug.sf.enable_gl_backpressure" "0"
    SET_PROP "system" "debug.sf.enable_transaction_tracing" "false"
    SET_PROP "system" "debug.sf.predict_hwc_composition_strategy" "0"
    SET_PROP "system" "debug.sf.treat_170m_as_sRGB" "1"
    SET_PROP "system" "debug.stagefright.c2inputsurface" "-1"
    SET_PROP "system" "media.stagefright.thumbnail.prefer_hw_codecs" "true"
    SET_PROP "system" "mediatek.wlan.ctia" "0"
    SET_PROP "system" "persist.log.tag.BufferQueueDump" "I"
    SET_PROP "system" "persist.log.tag.BufferQueueProducer" "I"
    SET_PROP "system" "persist.log.tag.GraphicBuffer" "I"
    SET_PROP "system" "persist.log.tag.SurfaceControl" "I"
    SET_PROP "system" "persist.sys.fuse.passthrough.enable" "true"
    SET_PROP "system" "persist.vendor.mdlog.flush_log_ratio" "0"
    SET_PROP "system" "persist.vendor.mtk.vilte.enable" "1"
    SET_PROP "system" "persist.vendor.pco5.radio.ctrl" "0"
    SET_PROP "system" "persist.vendor.pms_removable" "1"
    SET_PROP "system" "persist.vendor.vilte_support" "1"
    SET_PROP "system" "persist.vendor.vzw_device_type" "0"
    SET_PROP "system" "persist.vendor.wfc.sys_wfc_support" "1"
    SET_PROP "system" "qemu.hw.mainkeys" "0"
    SET_PROP "system" "ro.audio.flinger_standbytime_ms" "1000"
    SET_PROP "system" "ro.audio.ihaladaptervendorextension_enabled" "true"
    SET_PROP "system" "ro.audio.silent" "0"
    SET_PROP "system" "ro.audio.usb.period_us" "16000"
    SET_PROP "system" "ro.base_build" "noah"
    SET_PROP "system" "ro.config.per_app_memcg" "false"
    SET_PROP "system" "ro.iorapd.enable" "false"
    SET_PROP "system" "ro.kernel.qemu" "0"
    SET_PROP "system" "ro.kernel.zio" "38,108,105,16"
    SET_PROP "system" "ro.llndk.api_level" "202404"
    SET_PROP "system" "ro.logd.auditd.events" "false"
    SET_PROP "system" "ro.logd.auditd.main" "false"
    SET_PROP "system" "ro.mediatek.version.branch" "alps-mp-v0.mssi1.tc10sp"
    SET_PROP "system" "ro.mediatek.version.build.branch" ""
    SET_PROP "system" "ro.mediatek.version.release" "alps-mp-v0.mp1.tc10sp-V1.61.1"
    SET_PROP "system" "ro.mediatek.wlan.p2p" "1"
    SET_PROP "system" "ro.mediatek.wlan.wsc" "1"
    SET_PROP "system" "ro.mtk_perf_fast_start_win" "1"
    SET_PROP "system" "ro.mtk_perf_response_time" "1"
    SET_PROP "system" "ro.mtk_perf_simple_start_win" "1"
    SET_PROP "system" "ro.opengles.version" "196610"
    SET_PROP "system" "ro.property_service.async_persist_writes" "true"
    SET_PROP "system" "ro.surface_flinger.game_default_frame_rate_override" "60"
    SET_PROP "system" "ro.sys.usb.bicr" "no"
    SET_PROP "system" "ro.sys.usb.charging.only" "yes"
    SET_PROP "system" "ro.sys.usb.mtp.whql.enable" "0"
    SET_PROP "system" "ro.sys.usb.storage.type" "mtp"
    SET_PROP "system" "ro.vendor.customer_logpath" "/data"
    SET_PROP "system" "ro.vendor.have_aee_feature" "1"
    SET_PROP "system" "ro.vendor.mtk_flv_playback_support" "1"
    SET_PROP "system" "ro.vendor.mtk_omacp_support" "1"
    SET_PROP "system" "ro.vendor.mtk_telephony_add_on_policy" "0"
    SET_PROP "system" "ro.vendor.system.mtk_dmc_support" "1"
    SET_PROP "system" "ro.zygote.preload.enable" "0"
    SET_PROP "system" "sys.ipo.disable" "1"
    SET_PROP "system" "sys.ipo.pwrdncap" "2"
    SET_PROP "system" "vendor.af.dynamic.sleeptime.enable" "true"
    SET_PROP "system" "vendor.af.pausewait.enable" "false"
    SET_PROP "system" "vendor.af.threshold.src_and_effect_count" "5"
    SET_PROP "system" "vendor.mtk_thumbnail_optimization" "true"
    SET_PROP "system" "vendor.rild.libargs" "-d /dev/ttyC0"
    SET_PROP "system" "wifi.direct.interface" "p2p0"
    SET_PROP "system" "wifi.interface" "wlan0"
    SET_PROP "system" "wifi.tethering.interface" "ap0"

    else
    echo "Target device is not a Mediatek device. Ignoring"
fi
