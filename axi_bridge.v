`timescale 1ns / 1ps
module axi_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  wire                       aclk,
    input  wire                       aresetn,

    // AXI4-Lite Slave 接口
    input  wire [ADDR_WIDTH-1:0]      axi_awaddr,
    input  wire                       axi_awvalid,
    output wire                       axi_awready,

    input  wire [DATA_WIDTH-1:0]      axi_wdata,
    input  wire [3:0]                 axi_wstrb,
    input  wire                       axi_wvalid,
    output wire                       axi_wready,

    output wire [1:0]                 axi_bresp,
    output wire                       axi_bvalid,
    input  wire                       axi_bready,

    input  wire [ADDR_WIDTH-1:0]      axi_araddr,
    input  wire                       axi_arvalid,
    output wire                       axi_arready,

    output wire [DATA_WIDTH-1:0]      axi_rdata,
    output wire [1:0]                 axi_rresp,
    output wire                       axi_rvalid,
    input  wire                       axi_rready,

    // CPU 侧 wishbone-like 接口（连接到 cpu_core）
    output reg  [31:0]                sram_addr,
    output reg  [31:0]                sram_wdata,
    output reg  [3:0]                 sram_wen,
    output reg                        sram_en,
    input  wire [31:0]                sram_rdata
);

    reg aw_ready, w_ready, b_valid;
    reg ar_ready, r_valid;
    reg [DATA_WIDTH-1:0] rdata_reg;

    // 写通道
    assign axi_awready = aw_ready;
    assign axi_wready  = w_ready;
    wire write_handshake = axi_awvalid && aw_ready && axi_wvalid && w_ready;

    always @(posedge aclk) begin
        if (!aresetn) begin
            aw_ready <= 1'b1;
            w_ready  <= 1'b1;
        end else if (write_handshake) begin
            aw_ready <= 1'b0;
            w_ready  <= 1'b0;
        end else if (axi_bvalid && axi_bready) begin
            aw_ready <= 1'b1;
            w_ready  <= 1'b1;
        end
    end

    // 写响应
    always @(posedge aclk) begin
        if (!aresetn) b_valid <= 1'b0;
        else if (write_handshake) b_valid <= 1'b1;
        else if (axi_bready) b_valid <= 1'b0;
    end
    assign axi_bvalid = b_valid;
    assign axi_bresp  = 2'b00;  // OKAY

    // 读通道
    assign axi_arready = ar_ready;
    wire read_handshake = axi_arvalid && ar_ready;

    always @(posedge aclk) begin
        if (!aresetn) ar_ready <= 1'b1;
        else if (read_handshake) ar_ready <= 1'b0;
        else if (axi_rvalid && axi_rready) ar_ready <= 1'b1;
    end

    // 读数据
    always @(posedge aclk) begin
        if (!aresetn) begin
            r_valid   <= 1'b0;
            rdata_reg <= 32'b0;
        end else if (read_handshake) begin
            r_valid   <= 1'b1;
            rdata_reg <= sram_rdata;
        end else if (axi_rready) r_valid <= 1'b0;
    end
    assign axi_rvalid = r_valid;
    assign axi_rdata  = rdata_reg;
    assign axi_rresp  = 2'b00;  // OKAY

    // CPU 侧信号
    always @(posedge aclk) begin
        if (!aresetn) begin
            sram_en    <= 1'b0;
            sram_addr  <= 32'b0;
            sram_wdata <= 32'b0;
            sram_wen   <= 4'b0;
        end else if (write_handshake) begin
            sram_en    <= 1'b1;
            sram_addr  <= axi_awaddr;
            sram_wdata <= axi_wdata;
            sram_wen   <= axi_wstrb;
        end else if (read_handshake) begin
            sram_en    <= 1'b1;
            sram_addr  <= axi_araddr;
            sram_wen   <= 4'b0;
        end else begin
            sram_en    <= 1'b0;
        end
    end

endmodule