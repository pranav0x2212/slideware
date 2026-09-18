// -----------------------------------------------------------------------------
// rmc_dfi_pkg
//
// Shared parameters/typedefs for rmc_dfi_if.sv ONLY. Not an implementation
// package - no timing, no encoding logic, no FSM state types.
//
// Source of truth: ~/All_Git_Clones/rmc_theory/docs/dfi_5.2_interface_audit.md
// (Rounds 1-4, frozen) and docs/rmc_datapath_architecture.md. Round/section
// citations below (e.g. "R1 S1.2") refer to the audit.
//
// Any parameter tagged TODO/OPEN below is not a real number - it is a
// placeholder that makes the file elaborate. Do not treat it as a design
// decision; it must be resolved (and re-justified against the audit) before
// this skeleton becomes real RTL.
// -----------------------------------------------------------------------------

package rmc_dfi_pkg;

  // ---- scope anchors -----------------------------------------------------
  // 32-bit DDR5 sub-channel - the one hard, documented number in this file.
  // (rmc_datapath_architecture.md S4.2 / fig_mcc_block.py: "one channel
  // (32-bit DDR5 sub-channel)")
  parameter int unsigned DFI_DQ_WIDTH = 32;

  // Command-phase count for the _pN phase-vectored ports. RMC's stated scope
  // is gear 1:1 / 1:2 / 1:4 (fig_05_packer.py: "phase bundle @ 1:4"). 1:8 is
  // legal per DFI 5.2 S4.10 but explicitly OUT of RMC's stated scope
  // (R1 S1.3 item 2) - do not silently extend this interface to 1:8.
  parameter int unsigned DFI_PHASE_CNT_DFLT = 4;

  // DFI data-word count for the read-side _wN word-vectored ports
  // (dfi_rddata_wN / dfi_rddata_valid_wN, DFI 5.2 S4.10.4). Deliberately a
  // SEPARATE parameter from DFI_PHASE_CNT_DFLT: the audit does not confirm
  // word count equals phase count (R2 S2.3 / R3 S3.3 - "beats vs phases"
  // framing ambiguity, i.e. whether write/read data is realized as parallel
  // _pN/_wN bus replicas or a faster-clocked serializer is unresolved).
  // TODO/OPEN - default mirrors DFI_PHASE_CNT_DFLT only because that is the
  // one number RMC's docs give ("2*gear beats/mc_clk"); not a confirmed
  // word count.
  parameter int unsigned DFI_WORD_CNT_DFLT = 4;

  // Per-phase/per-word data unit width used on dfi_wrdata_pN / dfi_rddata_wN.
  // TODO/OPEN - DFI 5.2 Table 15/18 frames the write/read data bus width as
  // "generally twice the DRAM data bus width" at baseline, scaling further
  // with frequency ratio (S4.10.3/S4.10.4); RMC's docs never state whether
  // this port literally instantiates that convention or something else
  // (same "beats vs phases" ambiguity as DFI_WORD_CNT_DFLT above, R2 S2.3).
  // Defaulted to DFI_DQ_WIDTH only because that is the one hard number
  // available - NOT a confirmed per-replica width.
  parameter int unsigned DFI_WRDATA_UNIT_WIDTH_DFLT = DFI_DQ_WIDTH;
  parameter int unsigned DFI_RDDATA_UNIT_WIDTH_DFLT = DFI_DQ_WIDTH;

  // Current rank count. RMC's stated scope is single-rank today with an
  // explicit stated intent to go to 2 (R2 S2.3, "02_emit_timing_scoreboard.md:82
  // 'A10 pkg intent'"). dfi_wrdata_cs / dfi_rddata_cs / dfi_cs are latent
  // gaps the moment this exceeds 1 - see rmc_dfi_if.sv comments.
  parameter int unsigned N_RANKS_DFLT = 1;

  // dfi_alert_n uses its OWN "_aN" alert-lane index (DFI 5.2 Table 13,
  // audit heading literally "dfi_alert_n_aN"), NOT the command _pN phase
  // index. No inspected RMC source traces how many alert lanes exist -
  // TODO/OPEN, placeholder count only.
  parameter int unsigned DFI_ALERT_LANES_DFLT = 1;

  // Gear ratios RMC's own docs actually discuss (fig_05_packer.py, R1 S1.3).
  // 1:8 is DFI-5.2-legal but out of RMC's stated scope - listed here only
  // as documentation, not wired to anything in this skeleton.
  typedef enum logic [1:0] {
    DFI_GEAR_1_1 = 2'd0,
    DFI_GEAR_1_2 = 2'd1,
    DFI_GEAR_1_4 = 2'd2
  } dfi_gear_e;

endpackage : rmc_dfi_pkg
