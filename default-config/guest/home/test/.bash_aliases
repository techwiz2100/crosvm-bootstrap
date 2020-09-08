// Build related settings
function crosvm_build_env () {
export RUST_VERSION=1.45.2
export CARGO_HOME=/usr/local/cargo
export PATH=/usr/local/cargo/bin:$PATH
export RUSTFLAGS='--cfg hermetic'
}

// Variables to enable debugging
function graphics_debug_env () {
export MESA_DEBUG=1
export EGL_LOG_LEVEL=debug
export LIBGL_DEBUG=verbose
export WAYLAND_DEBUG=1
}

// XDG_RUNTIME_DIR
if test -z "${XDG_RUNTIME_DIR}"; then
    export XDG_RUNTIME_DIR=/tmp/${UID}-runtime-dir
    if ! test -d "${XDG_RUNTIME_DIR}"; then
        mkdir "${XDG_RUNTIME_DIR}"
        chmod 0700 "${XDG_RUNTIME_DIR}"
    fi
fi

// Add depot_tools to the path
export PATH=/build/depot_tools:$PATH
