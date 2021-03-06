##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##


require 'msf/core'


class Metasploit3 < Msf::Encoder::Xor

  def initialize
    super(
      'Name'             => 'Substitution encoder based on XOR',
      'Description'      => %q{
	    An encoder which takes all the unique shellcode bytes, randomizes
	    them to form a dictionary. Then the shellcode is encoded as offsets
	    in this dictionary. The offsets are also xored with a single byte 
	    key.
      },
      'Author'           => [ 'reubensammut' ],
      'Arch'             => ARCH_X86,
      'License'          => MSF_LICENSE,
      'Decoder'          =>
        {
          'KeySize'    => 1,
          'BlockSize'  => 1,
	  'KeyPack'    => 'C'
        })
  end

  #
  # Returns the decoder stub and sets the key offset
  #
  def decoder_stub(state)
    len = state.buf.length 

    decoder =
        "\xd9\xee" +			 # fldz 
        "\xd9\x74\x24\xf4" +		 # fnstenv [esp - 0xc]
        "\x5f" +			 # pop    edi
        "\x83\xc7\x22" +		 # add    edi, 0x22
        "\x8d\x37" +			 # lea    esi, [edi]
        "\x83\xc6" + [len].pack('C') + 	 # add    esi, (len + 1)
        "\x31\xc0" +			 # xor    eax, eax
        "\x8a\x07" +			 # mov     al, BYTE PTR [edi]
        "\x34X" +			 # xor     al, (xor key)
        "\x74\x0b" +			 # je     +11 
        "\x8d\x1e" +			 # lea    ebx, [esi]
        "\x01\xc3" +			 # add    ebx, eax
        "\x8a\x03" +			 # mov     al, BYTE PTR [ebx]
        "\x88\x07" +			 # mov    BYTE PTR [edi], al
        "\x47" +			 # inc    edi
        "\xeb\xef"			 # jmp    -17

    state.decoder_key_offset = 20

    return decoder
  end

  #
  # Creates the dictionary from which each shellcode byte should be chosen
  #
  def encode_begin(state)
    @dictionary = state.buf.split(//).sort.uniq.shuffle.join
  end

  #
  # Encode one byte by looking in the dictionary
  #
  def encode_block(state, block)
    buf = ((@dictionary.index(block[0]) + 1) ^ state.key).chr

    buf
  end

  #
  # Appends the key + dictionary
  #
  def encode_end(state)
    state.encoded << [state.key].pack('C') + @dictionary
  end


end
