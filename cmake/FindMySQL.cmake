#--------------------------------------------------------
# FindMySQL.cmake - ajustado para vcpkg (libmysql)
#--------------------------------------------------------

#-------------- FIND MYSQL_INCLUDE_DIR ------------------
FIND_PATH(MYSQL_INCLUDE_DIR mysql.h
        $ENV{MYSQL_INCLUDE_DIR}
        $ENV{MYSQL_DIR}/include
        C:/dev/vcpkg/installed/x64-windows/include/mysql
        C:/dev/vcpkg/installed/x64-windows/include
        /usr/include/mysql
        /usr/local/include/mysql
        /opt/mysql/mysql/include
        /opt/mysql/mysql/include/mysql
        /opt/mysql/include
        /opt/local/include/mysql5
        /usr/local/mysql/include
        /usr/local/mysql/include/mysql
        $ENV{ProgramFiles}/MySQL/*/include
        $ENV{SystemDrive}/MySQL/*/include
        PATH_SUFFIXES mysql)

#----------------- FIND MYSQL_LIB_DIR -------------------
IF (WIN32)
    IF (CMAKE_BUILD_TYPE STREQUAL Debug)
        SET(libsuffixDist debug)
        SET(libsuffixBuild Debug)
    ELSE ()
        SET(libsuffixDist opt)
        SET(libsuffixBuild Release)
        ADD_DEFINITIONS(-DDBUG_OFF)
    ENDIF ()

    FIND_LIBRARY(MYSQL_LIB
        NAMES mysqlclient libmariadb libmysql
        PATHS
            $ENV{MYSQL_DIR}/lib/${libsuffixDist}
            $ENV{MYSQL_DIR}/libmysql
            $ENV{MYSQL_DIR}/libmysql/${libsuffixBuild}
            $ENV{MYSQL_DIR}/client/${libsuffixBuild}
            $ENV{MYSQL_DIR}/libmysql/${libsuffixBuild}
            $ENV{ProgramFiles}/MySQL/*/lib/${libsuffixDist}
            $ENV{SystemDrive}/MySQL/*/lib/${libsuffixDist}
            C:/dev/vcpkg/installed/x64-windows/lib
            C:/dev/vcpkg/installed/x64-windows/lib/manual-link)
ELSE ()
    FIND_LIBRARY(MYSQL_LIB
        NAMES mysqlclient mariadbclient libmariadb libmariadbclient
        PATHS
            $ENV{MYSQL_DIR}/libmysql/.libs
            $ENV{MYSQL_DIR}/lib
            $ENV{MYSQL_DIR}/lib/mysql
            /usr/lib/mysql
            /usr/local/lib/mysql
            /usr/local/mysql/lib
            /usr/local/mysql/lib/mysql
            /opt/local/mysql5/lib
            /opt/local/lib/mysql5/mysql
            /opt/mysql/mysql/lib/mysql
            /opt/mysql/lib/mysql)
ENDIF ()

IF(MYSQL_LIB)
    GET_FILENAME_COMPONENT(MYSQL_LIB_DIR ${MYSQL_LIB} PATH)
ENDIF()

IF (MYSQL_INCLUDE_DIR AND MYSQL_LIB_DIR)
    SET(MYSQL_FOUND TRUE)

    INCLUDE_DIRECTORIES(${MYSQL_INCLUDE_DIR})
    LINK_DIRECTORIES(${MYSQL_LIB_DIR})

    FIND_LIBRARY(MYSQL_ZLIB zlib PATHS ${MYSQL_LIB_DIR})
    FIND_LIBRARY(MYSQL_YASSL yassl PATHS ${MYSQL_LIB_DIR})
    FIND_LIBRARY(MYSQL_TAOCRYPT taocrypt PATHS ${MYSQL_LIB_DIR})

    SET(MYSQL_CLIENT_LIBS ${MYSQL_LIB})

    IF (MYSQL_ZLIB)
        SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ${MYSQL_ZLIB})
    ENDIF ()

    IF (MYSQL_YASSL)
        SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ${MYSQL_YASSL})
    ENDIF ()

    IF (MYSQL_TAOCRYPT)
        SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ${MYSQL_TAOCRYPT})
    ENDIF ()

    IF (WIN32)
        SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ws2_32)
    ENDIF ()

    IF (APPLE)
        SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} iconv)
    ENDIF ()

    IF (UNIX)
        SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} "-ldl")
    ENDIF ()

    MESSAGE(STATUS "MySQL Include dir: ${MYSQL_INCLUDE_DIR}  library dir: ${MYSQL_LIB_DIR}")
    MESSAGE(STATUS "MySQL client libraries: ${MYSQL_CLIENT_LIBS}")
ELSE ()
    MESSAGE(FATAL_ERROR "Cannot find MySQL. Include dir: ${MYSQL_INCLUDE_DIR}  library dir: ${MYSQL_LIB_DIR}")
ENDIF ()