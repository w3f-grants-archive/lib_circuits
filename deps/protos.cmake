################################################################################
# compile the files under deps/protos/ using protoc from 3rd_party/protobuf.cmake
# https://cmake.org/cmake/help/latest/module/FindProtobuf.html

# set(Protobuf_SRC_ROOT_FOLDER ${protobuf_fetch_SOURCE_DIR})  # cf 3rd_party/protobuf.cmake
# DOES NOT work with FetchContent
# find_package(Protobuf)
# So instead we set up manually what we need
# set(Protobuf_LIBRARIES ${protobuf_fetch_BINARY_DIR})

# contains protobuf-config.cmake etc
# set(Protobuf_DIR ${protobuf_fetch_BINARY_DIR}/lib/cmake/protobuf)
# set(protobuf_MODULE_COMPATIBLE TRUE)
# find_package(Protobuf CONFIG REQUIRED)
# message(STATUS "Using protobuf ${protobuf_VERSION}")

# cf https://chromium.googlesource.com/external/github.com/grpc/grpc/+/refs/tags/v1.14.0/examples/cpp/helloworld/CMakeLists.txt#52

# "After using add_subdirectory, we can now use the grpc targets directly from
# this build."
set(_PROTOBUF_LIBPROTOBUF libprotobuf)
set(_PROTOBUF_PROTOC $<TARGET_FILE:protoc>)
# needed for eg build/protos/skcd.pb.h:10:10: fatal error: 'google/protobuf/port_def.inc' file not found
set(Protobuf_INCLUDE_DIRS ${protobuf_fetch_SOURCE_DIR}/src)

# will gather all the "${CMAKE_BINARY_DIR}/protos/aaa.pb.cc
# needed for add_library below
set(PROTO_GENERATED_CPP "")

function(compile_proto_cpp SRC_PROTO_PATH)

    # Proto file
    # eg: /home/.../deps/protos/circuits/circuit.proto
    get_filename_component(hw_proto "${SRC_PROTO_PATH}" ABSOLUTE)
    # eg /home/.../deps/protos/circuits
    # needed for Protobuf INCLUDE DIR
    get_filename_component(hw_proto_path "${hw_proto}" PATH)
    # eg circuit
    get_filename_component(src_proto_name "${SRC_PROTO_PATH}" NAME_WE)
    message(STATUS "hw_proto : ${hw_proto}")
    message(STATUS "hw_proto_path : ${hw_proto_path}")
    message(STATUS "src_proto_name : ${src_proto_name}")

    # Generated sources
    set(hw_proto_srcs
        "${CMAKE_BINARY_DIR}/protos/${src_proto_name}.pb.cc"
    )
    set(hw_proto_hdrs
        "${CMAKE_BINARY_DIR}/protos/${src_proto_name}.pb.h"
    )
    add_custom_command(
        OUTPUT "${hw_proto_srcs}" "${hw_proto_hdrs}"
        COMMAND ${_PROTOBUF_PROTOC}
        ARGS --cpp_out "${CMAKE_BINARY_DIR}/protos/"
            -I "${hw_proto_path}"
            "${hw_proto}"
        DEPENDS "${hw_proto}")

    set(PROTO_GENERATED_CPP "${PROTO_GENERATED_CPP};${hw_proto_srcs};" PARENT_SCOPE)
endfunction(compile_proto_cpp)

################################################################################

compile_proto_cpp("./deps/protos/skcd/skcd.proto")

################################################################################

# add a library to avoid "polluting" global include/flags with proto
add_library(interstellar_protos
    ${PROTO_GENERATED_CPP}
)

target_include_directories(interstellar_protos
    PUBLIC
    ${Protobuf_INCLUDE_DIRS}
    # where the protos.cpp will be generated by protoc
    ${CMAKE_BINARY_DIR}/protos
)

target_link_libraries(interstellar_protos
    PRIVATE
    ${_PROTOBUF_LIBPROTOBUF}
)
