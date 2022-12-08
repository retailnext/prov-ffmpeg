cmake_minimum_required(VERSION 2.8)
project(FFmpeg NONE)

include(ExternalProject)

set(EXTERNAL_DIR ${CMAKE_BINARY_DIR}/external)

set (INSTALL_LIBDIR "lib")

ExternalProject_Add (
    Yasm
    PREFIX ${EXTERNAL_DIR}
    BINARY_DIR ${EXTERNAL_DIR}/src/Yasm
    URL /shared/yasm-1.3.0.tar.gz
    CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make -j $ENV{NUM_PROCESSORS} install
    INSTALL_COMMAND ""
)

ExternalProject_Add (
    x264
    PREFIX ${EXTERNAL_DIR}
    BINARY_DIR ${EXTERNAL_DIR}/src/x264
    URL /shared/x264-snapshot-20171023-2245-stable.tar.bz2
    CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX} --enable-shared --disable-gpl
    BUILD_COMMAND make -j $ENV{NUM_PROCESSORS} install
    INSTALL_COMMAND ""
)

ExternalProject_Add (
    FFmpeg
    PREFIX ${EXTERNAL_DIR}
    BINARY_DIR ${EXTERNAL_DIR}/src/FFmpeg
    URL /shared/ffmpeg-$ENV{RN_VERSION}.tar.bz2
    CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX} --enable-libx264 --enable-shared --disable-filter=mp --enable-gpl
    BUILD_COMMAND make -j $ENV{NUM_PROCESSORS} install
    INSTALL_COMMAND /shared/relocate.sh ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig  ${RPM_INSTALL_DIR}
    STEP_TARGETS sed
)

ExternalProject_Get_Property(FFmpeg source_dir)

ExternalProject_Add_Step (FFmpeg sed
    DEPENDEES download
    DEPENDERS configure
    COMMAND /bin/sed -i "s/^die_license_disabled gpl libx264$/#die_license_disabled gpl libx264/" ${source_dir}/configure > /dev/null
)

add_dependencies (FFmpeg x264)
add_dependencies (x264 Yasm)

install (DIRECTORY ${CMAKE_INSTALL_PREFIX}/include/
    DESTINATION include
    COMPONENT devel
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE
                GROUP_READ
                WORLD_READ
    )

install (DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib/
    DESTINATION ${INSTALL_LIBDIR}
    COMPONENT devel
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                GROUP_READ GROUP_EXECUTE
                WORLD_READ WORLD_EXECUTE
    )

install (DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin/
    DESTINATION bin
    COMPONENT devel
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                GROUP_READ GROUP_EXECUTE
                WORLD_READ WORLD_EXECUTE
    )

install (DIRECTORY ${CMAKE_INSTALL_PREFIX}/share/
    DESTINATION share
    COMPONENT devel
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE
                GROUP_READ
                WORLD_READ
    )

#
# runtime
install (DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib/
    DESTINATION ${INSTALL_LIBDIR}
    COMPONENT runtime
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                GROUP_READ GROUP_EXECUTE
                WORLD_READ WORLD_EXECUTE
    PATTERN "*.a" EXCLUDE
    PATTERN "*.pc" EXCLUDE
    )

install (DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin/
    DESTINATION bin
    COMPONENT runtime
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                GROUP_READ GROUP_EXECUTE
                WORLD_READ WORLD_EXECUTE
    )

#
# cpack
#
set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "FFmpeg Library Build")
set(CPACK_PACKAGE_VENDOR "FFmpeg.org, built by RetailNext")
set(CPACK_RPM_PACKAGE_RELEASE "1%{?dist}")
set(CPACK_PACKAGING_INSTALL_PREFIX ${RPM_INSTALL_DIR})
set(CPACK_RPM_COMPONENT_INSTALL ON)

include(CPack)
