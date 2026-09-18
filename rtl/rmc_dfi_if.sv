// -----------------------------------------------------------------------------
// rmc_dfi_if
//
// PORT/INTERFACE SKELETON ONLY. No FSMs, no datapath, no serializers, no
// protocol/timing logic, no PHY behavior. This file exists so a future RTL
// implementation has a concrete, audit-checked starting point for the
// RMC-core <-> DFI 5.2 <-> PHY boundary. It does not implement anything and
// does not silently resolve any open architectural question - every such
// item is called out inline as TODO/OPEN/GAP-ARCH/STUB/AMBIGUOUS, matching
// the vocabulary used in the source audit.
//
// Source of truth (do not drift from these without re-running the audit):
//   ~/All_Git_Clones/rmc_theory/docs/dfi_5.2_interface_audit.md   (Rounds 1-4, FROZEN)
//   ~/All_Git_Clones/rmc_theory/docs/rmc_datapath_architecture.md
// Citations below ("R1 S1.2", "R4 S4.3", etc.) refer to the audit's own
// round/section numbering.
//
// Scope match to the audit: DDR5-without-RCD, single 32-bit DDR5 sub-channel,
// gear 1:1/1:2/1:4 (1:8 explicitly out of scope, R1 S1.3 item 2), current
// N_RANKS=1 with a stated intent to go to 2 (R2 S2.3).
//
// This is NOT a DFI clock definition. DFI 5.2 does not itself define a
// dfi_clk signal - the DFI clock domain is implicit in the spec. mc_clk/
// mc_rst_n below are ordinary MC-side ports this interface instance needs
// to exist; they are NOT part of the DFI 5.2 signal set and must not be
// confused with dfi_reset_n (the real DFI 5.2 protocol signal, below).
// -----------------------------------------------------------------------------

interface rmc_dfi_if
  import rmc_dfi_pkg::*;
#(
  parameter int unsigned PHASE_CNT         = rmc_dfi_pkg::DFI_PHASE_CNT_DFLT,
  parameter int unsigned WORD_CNT          = rmc_dfi_pkg::DFI_WORD_CNT_DFLT,        // TODO/OPEN - see pkg
  parameter int unsigned N_RANKS           = rmc_dfi_pkg::N_RANKS_DFLT,
  parameter int unsigned ALERT_LANES       = rmc_dfi_pkg::DFI_ALERT_LANES_DFLT,     // TODO/OPEN - see pkg
  parameter int unsigned WRDATA_UNIT_WIDTH = rmc_dfi_pkg::DFI_WRDATA_UNIT_WIDTH_DFLT, // TODO/OPEN - see pkg
  parameter int unsigned RDDATA_UNIT_WIDTH = rmc_dfi_pkg::DFI_RDDATA_UNIT_WIDTH_DFLT, // TODO/OPEN - see pkg
  // dfi_address per-phase width. NOT documented anywhere in the current
  // authoritative sources - rmc_datapath_architecture.md S3: "No numeric
  // width is asserted for op, tag, or sram_addr... OPEN"; R1 S1.2: RMC never
  // shows the bit-level packing of the micro-op into the actual DDR5 CA
  // opcode DFI puts on this (narrow, SDR) bus. Default of 1 is a syntactic
  // placeholder ONLY so this file elaborates - it is not a width decision.
  parameter int unsigned CA_WIDTH          = 1,   // TODO/OPEN - R1 S1.2, width not specified by any inspected source
  // dfi_error_info / freq-ratio field widths. Not traced at signal level by
  // any audit round - same "placeholder, not a decision" treatment as CA_WIDTH.
  parameter int unsigned ERROR_INFO_WIDTH  = 1,   // TODO/OPEN - R4 S4.3, width unspecified
  parameter int unsigned FREQ_RATIO_WIDTH  = 1,   // TODO/OPEN - R1 S1.3 item 3 / R4 S4.3, CSR-duplication question unresolved
  parameter int unsigned FREQ_FSP_WIDTH    = 1,   // TODO/OPEN - see FREQ_RATIO_WIDTH
  parameter int unsigned FREQUENCY_WIDTH   = 1    // TODO/OPEN - see FREQ_RATIO_WIDTH
) (
  // Not DFI 5.2 signals - ordinary MC-side clock/reset for this interface
  // instance. Distinct from dfi_reset_n below.
  input logic mc_clk,
  input logic mc_rst_n
);

  // ===========================================================================
  // Command Interface - MC -> PHY  (DFI 5.2 S3.1 / S4.3, audit Round 1)
  // ===========================================================================

  // Confirmed-driven by RMC today (PHASE_PACKER, gear 1:N, FSM-commit).
  // dfi_address/dfi_cs are the ONLY two command-interface signals RMC's
  // current docs actually name (R1 S1.1: "the entire explicit command-
  // interface signal vocabulary in the authoritative source set").
  logic [CA_WIDTH-1:0]   dfi_address [PHASE_CNT];  // TODO/OPEN - R1 S1.2: micro-op {row/col} -> DDR5 CA opcode translation is undocumented
  logic [N_RANKS-1:0]    dfi_cs      [PHASE_CNT];  // GAP-ARCH - R1 S1.2: rank -> dfi_cs bit mapping named only in the superseded FAB doc

  // Legacy dfi_act_n/dfi_ras_n/dfi_cas_n/dfi_we_n/dfi_bank/dfi_bg/dfi_cid are
  // DELIBERATELY NOT declared here: DFI 5.2 Table 4 marks them "Required for
  // DDR1-DDR4[/LPDDR1]" only, i.e. NOT required for DDR5 (R1 S1.2). Command
  // encoding for DDR5 rides entirely on dfi_address; RMC's phase-packer docs
  // are "correctly scoped to DFI-5.2-for-DDR5" by omitting them (R1 S1.2).
  //
  // TODO/OPEN CONFLICT - do not resolve by adding or omitting a port:
  // RMC_MR_Programming_and_Power_Management_v1_9_11.md:131-132 names an
  // MR-write datapath "Stage 0 -> Stage 4 -> dfi_address/dfi_cs_n/dfi_act_n/
  // dfi_wrdata/dfi_wrdata_en" - i.e. a DIFFERENT current GEN3 doc names
  // dfi_act_n/dfi_cs_n, contradicting both DFI 5.2's DDR5 exclusion and the
  // phase-packer's address-only model (R1 S1.2). This is an unresolved
  // cross-doc inconsistency, not a decided port. If/when resolved, it would
  // look like:
  //   logic dfi_act_n [PHASE_CNT];  // only if MR/PM doc's model wins - NOT decided
  // Do not uncomment without re-checking the audit.

  logic [PHASE_CNT-1:0]  dfi_reset_n;          // GAP-ARCH - R1 S1.2: required for DDR5 (Table 4), no current doc names it or shows Init FSM driving it (the DFI_MUX hook exists, the signal drive doesn't)
  logic [PHASE_CNT-1:0]  dfi_2n_mode;          // GAP-ARCH - R1 S1.2: REQUIRED for DDR5 (not optional, Table 4), not present in any current doc
  logic [PHASE_CNT-1:0]  dfi_cs_geardown;      // GAP-ARCH, lowest priority - R1 S1.2: optional for DDR5, not present in any current doc
  logic [PHASE_CNT-1:0]  dfi_dram_clk_disable; // GAP-ARCH - R1 S1.2: required for ALL DRAMs, not mentioned anywhere current or superseded
  logic [PHASE_CNT-1:0]  dfi_parity_in;        // GAP-ARCH, conditional - R1 S1.2: required only if CA parity/CRC supported; no current doc computes it

  // dfi_odt is DELIBERATELY NOT declared: DFI 5.2 Table 4 does not require
  // it for DDR5 (only DDR2/DDR3/DDR4/LPDDR3), and no current RMC doc drives
  // or names it (R1 S1.2). Per the audit this should carry an explicit
  // "N/A for our DDR5 channel" note rather than silent omission - this
  // comment IS that note.

  // dfi_cke_pN - AMBIGUOUS, TODO/OPEN, NOT silently included or excluded.
  // RMC_MR_Programming_and_Power_Management_v1_9_11.md SB.2/B.4/B.9 makes
  // this load-bearing for PD/SR power-state entry. DFI 5.2 does NOT require
  // it for DDR5 (Table 4) and instead defines an abstracted Low Power
  // Control Interface (dfi_lp_ctrl_req/ack, dfi_lp_data_req/ack, S3.6) that
  // RMC's docs never mention. Whether RMC's rank-level dfi_cke toggle is
  // DFI-5.2-compliant for a DDR5-only channel, or should instead/additionally
  // drive the Low Power Control Interface, is unresolved (R1 S1.2). Declared
  // here so the port exists for review, not because the question is decided.
  logic [N_RANKS-1:0]    dfi_cke [PHASE_CNT];  // TODO/OPEN - R1 S1.2

  // Status-interface signals that also gate command-issue readiness
  // (DFI 5.2 S3.5.3-3.5.5, Table 23). Referenced only in the superseded FAB
  // doc and flagged as an unresolved possible CSR duplication in
  // RMC_APB_Interface.md and the MR/PM doc's own "formal CSR model
  // incomplete" note (R1 S1.3 item 3 / R4 S4.3). Declared as scalar
  // placeholders only - do not invent how these would be wired to PHASE_PACKER.
  logic [FREQ_RATIO_WIDTH-1:0] dfi_cmd_freq_ratio;   // TODO/OPEN - R1 S1.3 item 3
  logic [FREQ_RATIO_WIDTH-1:0] dfi_data_freq_ratio;  // TODO/OPEN - R1 S1.3 item 3
  logic [FREQ_FSP_WIDTH-1:0]   dfi_freq_fsp;         // TODO/OPEN - R4 S4.3, valid only while dfi_init_start asserted per DFI 5.2
  logic [FREQUENCY_WIDTH-1:0]  dfi_frequency;        // TODO/OPEN - R4 S4.3


  // ===========================================================================
  // Write Data Interface - MC -> PHY  (DFI 5.2 S3.2 / S4.7, audit Round 2)
  // Generation-independent: Table 4 lists these "Required for all DRAMs" -
  // no DDR4/DDR5 carve-out (R2 S2.1). Phase-vectored (_pN), same replication
  // rule as the command interface (S3.2.4).
  // ===========================================================================

  logic [WRDATA_UNIT_WIDTH-1:0]     dfi_wrdata      [PHASE_CNT];  // sufficient as-is per audit - data-carrying signal itself is well-modeled (R2 S2.3)
  logic [WRDATA_UNIT_WIDTH/8-1:0]   dfi_wrdata_mask [PHASE_CNT];  // AMBIGUOUS - R2 S2.3: ADEC's documented sub-burst byte-lane placement implies a real masking need the datapath figures never carry to this boundary; not confirmed deliberate-omission vs unmodeled gap
  logic                             dfi_wrdata_en   [PHASE_CNT];  // GAP-ARCH - R2 S2.3/S2.4/S2.5: not driven anywhere; needs a NEW output port and a second, independently-timed tap (tphy_wrlat vs tphy_wrdata) distinct from WL_line's single launch-delay model. Not a naming fix.
  logic [N_RANKS-1:0]               dfi_wrdata_cs   [PHASE_CNT];  // GAP-ARCH, latent until multi-rank - R2 S2.3: required whenever >1 chip select exists; currently 100% unaddressed, becomes real the moment N_RANKS>1


  // ===========================================================================
  // Read Data Interface - PHY -> MC  (DFI 5.2 S3.3 / S4.8, audit Round 3)
  // Generation-independent (R3 S3.1). dfi_rddata/dfi_rddata_valid are
  // WORD-vectored (_wN) per DFI 5.2 S4.10.4 - explicitly NOT the same
  // vectoring as the command/write-data phase (_pN) convention. Only
  // dfi_rddata_en follows the command-phase (_pN) convention.
  // ===========================================================================

  logic [RDDATA_UNIT_WIDTH-1:0] dfi_rddata       [WORD_CNT];   // sufficient as-is per audit - data-carrying signal itself is well-modeled (R3 S3.3), mirrors write side
  logic                         dfi_rddata_valid [WORD_CNT];   // GAP-ARCH, MOST CONSEQUENTIAL GAP OF THE AUDIT - R3 S3.3/S3.4: not driven/consumed anywhere; RL_line's fixed-CL, no-signal timing model is only correct under an UNSTATED fixed-PHY-latency assumption - DFI 5.2 defines tphy_rdlat as a MAXIMUM, not a fixed value, and expects the MC to react to this signal, not just count cycles. This is a correctness gap, not just an incomplete pinout.
  logic                         dfi_rddata_en    [PHASE_CNT];  // GAP-ARCH - R3 S3.3: not driven anywhere; new MC->PHY output port needed, same shape as dfi_wrdata_en
  logic [N_RANKS-1:0]           dfi_rddata_cs    [PHASE_CNT];  // GAP-ARCH, latent until multi-rank - R3 S3.3: read-side counterpart of dfi_wrdata_cs, same treatment

  // dfi_rddata_dnv (_wN) and dfi_rddata_dbi (_wN) are DELIBERATELY NOT
  // declared: Table 4 requires dfi_rddata_dnv for LPDDR2 only, and
  // dfi_rddata_dbi for DDR4/LPDDR4/LPDDR5 only - neither applies to plain
  // DDR5-without-RCD (R3 S3.1/S3.3). Consistent with scope, not an omission.

  // Read data word rotation / resynchronization (DFI 5.2 S4.10.4.1-4.10.4.2)
  // is NOT modeled here as separate ports - DFI 5.2 itself carves out an
  // escape hatch for systems that always transfer full-ratio-multiple bursts
  // (S4.10.4, p.156), and RMC's "one full 512b line per packet" invariant
  // MAY already satisfy that, but no current doc states this as a deliberate
  // decision (R3 S3.3). AMBIGUOUS, not confirmed either way - flagged here,
  // not resolved by adding or omitting a data-word-pointer port.


  // ===========================================================================
  // Init / Status / Error Interface  (DFI 5.2 S3.5 / S3.7 / S4.1-4.2 / S4.14,
  // audit Round 4). Scalar - not phase- or word-vectored, except dfi_alert_n
  // which uses its own "_aN" alert-lane index.
  // ===========================================================================

  // MC -> PHY
  logic dfi_init_start;    // GAP-ARCH (signal-level) - R4 S4.3: DFI_MUX/init_done is "the cleanest confirmed mapping in the whole trace" architecturally, but no current doc ties any Init sub-FSM state to the actual assert/wait/de-assert sequence this signal requires.
                            // TODO/OPEN, SEPARATE ISSUE - R4 S4.3: RMC's init_done is documented as a ONE-WAY LATCH ("Two hard rules (KB S10)": init drives DFI at boot, scheduler inherits the port forever). DFI 5.2 S3.5.4 reuses this same signal for a MID-OPERATION frequency-change handshake, which a one-way latch cannot represent. Fine if RMC's frequency ratio is meant to be static for system life; conflicts with DFI 5.2 otherwise. No current doc states which is intended - do not assume either answer in a future implementation.

  // PHY -> MC
  logic dfi_init_complete; // GAP-ARCH (signal-level) - same finding as dfi_init_start above

  // PHY -> MC. STUB, not merely GAP-ARCH: fig_13_backend.py draws an
  // explicit "ALERT_n MON (stub)" block with a DASHED input arrow labeled
  // dfi_alert_n and a dashed output toward COMPLETION (R4 S4.3). No timing
  // model exists against the self-timed wr_done path - a late alert arriving
  // after wr_done has already been pushed to RESP_AFIFO is a real timing
  // scenario with no current answer (R4 S4.5).
  logic [ALERT_LANES-1:0] dfi_alert_n; // STUB - R4 S4.3/S4.5

  // PHY -> MC. Optional interface (DFI 5.2 S3.7); absent from RMC entirely.
  // Low severity - DFI 5.2 itself gives only best-effort command correlation
  // (S4.14: "not always possible to correlate the error with a specific
  // command"), so RMC's eventual handling has real design freedom here.
  logic                        dfi_error;       // GAP-ARCH, low severity - R4 S4.3
  logic [ERROR_INFO_WIDTH-1:0] dfi_error_info;  // GAP-ARCH, low severity - R4 S4.3, encoding not specified anywhere


  // ===========================================================================
  // Modports - direction is authoritative here. mc = RMC-core side,
  // phy = PHY side. Every signal above must appear in exactly one direction
  // in each modport; there is no bidirectional DFI 5.2 signal in this set.
  // ===========================================================================

  modport mc (
    input  mc_clk, mc_rst_n,
    // command (MC -> PHY)
    output dfi_address, dfi_cs, dfi_reset_n, dfi_2n_mode, dfi_cs_geardown,
           dfi_dram_clk_disable, dfi_parity_in, dfi_cke,
           dfi_cmd_freq_ratio, dfi_data_freq_ratio, dfi_freq_fsp, dfi_frequency,
    // write data (MC -> PHY)
    output dfi_wrdata, dfi_wrdata_mask, dfi_wrdata_en, dfi_wrdata_cs,
    // read data (MC drives the request side, PHY drives the return side)
    output dfi_rddata_en, dfi_rddata_cs,
    input  dfi_rddata, dfi_rddata_valid,
    // init / status / error
    output dfi_init_start,
    input  dfi_init_complete, dfi_alert_n, dfi_error, dfi_error_info
  );

  modport phy (
    // command (MC -> PHY)
    input  dfi_address, dfi_cs, dfi_reset_n, dfi_2n_mode, dfi_cs_geardown,
           dfi_dram_clk_disable, dfi_parity_in, dfi_cke,
           dfi_cmd_freq_ratio, dfi_data_freq_ratio, dfi_freq_fsp, dfi_frequency,
    // write data (MC -> PHY)
    input  dfi_wrdata, dfi_wrdata_mask, dfi_wrdata_en, dfi_wrdata_cs,
    // read data
    input  dfi_rddata_en, dfi_rddata_cs,
    output dfi_rddata, dfi_rddata_valid,
    // init / status / error
    input  dfi_init_start,
    output dfi_init_complete, dfi_alert_n, dfi_error, dfi_error_info
  );

endinterface : rmc_dfi_if
