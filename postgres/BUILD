load("@rules_foreign_cc//foreign_cc:defs.bzl", "meson")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")

meson(
    name = "compile_and_install",
    lib_source = "@postgres_src//:src_all",
    out_binaries = ["postgres", "initdb", "pg_ctl", "pg_isready"],
    out_data_dirs = ["lib", "share"],
)

filegroup(
    name = "installed_files",
    srcs = [":compile_and_install"],
    output_group = "gen_dir",
)

pkg_tar(
    name = "postgres",
    srcs = [":installed_files"],
    package_dir = "/",
    strip_prefix = "",
    visibility = ["//visibility:public"],
)
