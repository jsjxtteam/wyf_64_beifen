`timescale 1ns / 1ps
module mycpu_top_axi (
    input  wire        aclk,
    input  wire        aresetn,

    // AXI4-Lite 接口（暴露给外部）
    input  wire [31:0] axi_awaddr,
    input  wire        axi_awvalid,
    output wire        axi_awready,
    input  wire [31:0] axi_wdata,
    input  wire [3:0]  axi_wstrb,
    input  wire        axi_wvalid,
    output wire        axi_wready,
    output wire [1:0]  axi_bresp,
    output wire        axi_bvalid,
    input  wire        axi_bready,
    input  wire [31:0] axi_araddr,
    input  wire        axi_arvalid,
    output wire        axi_arready,
    output wire [31:0] axi_rdata,
    output wire [1:0]  axi_rresp,
    output wire        axi_rvalid,
    input  wire        axi_rready,

    // debug 接口（func_test 必须保留）
    output wire [31:0] debug_wb_pc,
    output wire [3:0]  debug_wb_rf_wen,
    output wire [4:0]  debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

    // 内部 SRAM 信号
    wire [31:0] sram_addr;
    wire [31:0] sram_wdata;
    wire [31:0] sram_rdata;
    wire [3:0]  sram_wen;
    wire        sram_en;

    // 原有 CPU 核心实例化
    cpu_core u_cpu_core (
        .clk                (aclk),
        .resetn             (aresetn),
        .sram_addr          (sram_addr),
        .sram_wdata         (sram_wdata),
        .sram_wen           (sram_wen),
        .sram_en            (sram_en),
        .sram_rdata         (sram_rdata),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_rf_wen    (debug_wb_rf_wen),
        .debug_wb_rf_wnum   (debug_wb_rf_wnum),
        .debug_wb_rf_wdata  (debug_wb_rf_wdata)
    );

    // AXI 桥实例化
    axi_bridge u_axi_bridge (
        .aclk               (aclk),
        .aresetn            (aresetn),
        .axi_awaddr         (axi_awaddr),
        .axi_awvalid        (axi_awvalid),
        .axi_awready        (axi_awready),
        .axi_wdata          (axi_wdata),
        .axi_wstrb          (axi_wstrb),
        .axi_wvalid         (axi_wvalid),
        .axi_wready         (axi_wready),
        .axi_bresp          (axi_bresp),
        .axi_bvalid         (axi_bvalid),
        .axi_bready         (axi_bready),
        .axi_araddr         (axi_araddr),
        .axi_arvalid        (axi_arvalid),
        .axi_arready        (axi_arready),
        .axi_rdata          (axi_rdata),
        .axi_rresp          (axi_rresp),
        .axi_rvalid         (axi_rvalid),
        .axi_rready         (axi_rready),
        .sram_addr          (sram_addr),
        .sram_wdata         (sram_wdata),
        .sram_wen           (sram_wen),
        .sram_en            (sram_en),
        .sram_rdata         (sram_rdata)
    );

endmodule