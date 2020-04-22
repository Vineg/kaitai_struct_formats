meta:
  id: avi
  endian: le
  title: Microsoft AVI file format
  ks-version: 0.7
  license: CC0-1.0
doc-ref: https://msdn.microsoft.com/en-us/library/ms779636.aspx
doc-ref: http://www.jmcgowan.com/odmlff2.pdf
seq:
  - id: magic1
    contents: RIFF
  - id: file_size
    type: u4
  - id: magic2
    contents: 'AVI '
  - id: data
    type: blocks
    size: file_size - 4
  - id: extra_data
    type: avix
    repeat: eos
types:
  avix:
    seq:
      - id: magic21
        contents: RIFF
      - id: file_size2
        type: u4
      - id: magic22
        contents: 'AVIX'
      - id: data2
        type: blocks
        size: file_size2 - 4
  # either a chunk or list
  blocks:
    seq:
      - id: entries
        type: block
        repeat: eos
  block:
    seq:
      - id: four_cc
        type: u4
        enum: chunk_type
      - id: block_size
        type: u4
      - id: data
        size: block_size
        type:
          switch-on: four_cc
          cases:
            'chunk_type::list': list_body
            'chunk_type::avih': avih_body
            'chunk_type::strh': strh_body
            'chunk_type::indx': indx_body
            'chunk_type::ix00': ix_body
  avisuperindex_entry:
    seq:
      - id: offset
        type: u8
      - id: size
        type: u4
      - id: duration
        type: u4
  avifieldindex_entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: field_offset
        type: u4
  avistdindex_entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
  indx_body:
    seq:
      - id: longs_per_entry
        type: u2
      - id: index_sub_type
        type: u1
      - id: index_type
        type: u1
      - id: entries_in_use
        type: u4
      - id: chunk_id
        type: u4
      - id: reserved
        size: 12
      - id: entries
        type: avisuperindex_entry
        repeat: expr
        repeat-expr: entries_in_use
  ix_body:
    seq:
      - id: longs_per_entry
        type: u2
      - id: index_sub_type
        type: u1
      - id: index_type
        type: u1
      - id: entries_in_use
        type: u4
      - id: chunk_id
        type: u4
      - id: base_offset
        type: u8
      - id: reserved
        size: 4
      - id: entries
        type:
          switch-on: index_sub_type
          cases:
            0: avistdindex_entry
            1: avifieldindex_entry
        repeat: expr
        repeat-expr: entries_in_use
  list_body:
    seq:
      - id: list_type
        type: u4
        enum: chunk_type
      - id: data
        type: blocks
  avih_body:
    doc: Main header of an AVI file, defined as AVIMAINHEADER structure
    doc-ref: https://msdn.microsoft.com/en-us/library/ms779632.aspx
    seq:
      - id: micro_sec_per_frame
        type: u4
      - id: max_bytes_per_sec
        type: u4
      - id: padding_granularity
        type: u4
      - id: flags
        type: u4
      - id: total_frames
        type: u4
      - id: initial_frames
        type: u4
      - id: streams
        type: u4
      - id: suggested_buffer_size
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: reserved
        size: 16
  strh_body:
    doc: Stream header (one header per stream), defined as AVISTREAMHEADER structure
    doc-ref: https://msdn.microsoft.com/en-us/library/ms779638.aspx
    seq:
      - id: fcc_type
        type: u4
        enum: stream_type
        doc: Type of the data contained in the stream
      - id: fcc_handler
        type: u4
        enum: handler_type
        doc: Type of preferred data handler for the stream (specifies codec for audio / video streams)
      - id: flags
        type: u4
      - id: priority
        type: u2
      - id: language
        type: u2
      - id: initial_frames
        type: u4
      - id: scale
        type: u4
      - id: rate
        type: u4
      - id: start
        type: u4
      - id: length
        type: u4
      - id: suggested_buffer_size
        type: u4
      - id: quality
        type: u4
      - id: sample_size
        type: u4
      - id: frame
        type: rect
  strf_body:
    doc: Stream format description
  rect:
    seq:
      - id: left
        type: s2
      - id: top
        type: s2
      - id: right
        type: s2
      - id: bottom
        type: s2
enums:
  chunk_type:
    0x31786469: idx1
    0x4b4e554a: junk
    0x4f464e49: info
    0x54465349: isft
    0x5453494c: list
    0x66727473: strf
    0x68697661: avih
    0x68727473: strh
    0x69766f6d: movi
    0x6c726468: hdrl
    0x6c727473: strl
    0x78646E69: indx
    0x30307869: ix00
  stream_type:
    0x7364696d: mids # MIDI stream
    0x73646976: vids # Video stream
    0x73647561: auds # Audio stream
    0x73747874: txts # Text stream
  handler_type:
    0x00000055: mp3
    0x00002000: ac3
    0x00002001: dts
    0x64697663: cvid
    0x64697678: xvid
