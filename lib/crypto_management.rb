module DW

  # Set of classes and methods for handling crypto operations across
  # the platform
  #
  module CryptoManagement

    require 'digest/sha1'
    require 'active_support/secure_random'

    # Provides static methods for encryption and decryption
    #
    class Cryptography
      @@PRIME   = 9576890767
      @@IPRIME  = 1039154543
      @@MAXID   = 2147483647
      @@BASE    = 36

      # Generic method to decrypt strings encrypted using the aes-128 cipher
      #
      def self.decrypt(cipherBase64,phrase)
        cipher  = Base64.decode64(cipherBase64)

        aes     = OpenSSL::Cipher::Cipher.new("aes-128-cbc").decrypt
        aes.iv  = cipher.slice(0,16)
        aes.key = (Digest::SHA256.digest(phrase)).
                    slice(0,16)
        cipher  = cipher.slice(16..-1)

        aes.update(cipher) + aes.final
      end

      # Encrypts the text sing the given salt
      #
      def self.encrypt_with_salt(text,salt)
        Digest::SHA1.hexdigest("--#{salt}--#{text}--")
      end

      # Generates a random salt string. 
      #
      def self.generate_salt
        self.encrypt_with_salt(Time.now,SecureRandom.hex(10)) 
      end

      # Obfuscate the given integer and convert to a different base while still 
      # keeping it recoverable
      # Ref - http://blog.michaelgreenly.com/2008/01/obsificating-ids-in-urls.html
      # Ref - http://en.wikipedia.org/wiki/Modular_multiplicative_inverse
      #
      def self.obfuscate(integer)
         (integer * @@PRIME & @@MAXID).to_s(@@BASE)
      end
      
      # The deobfuscation compliment of self.obfuscated
      #
      def self.deobfuscate(obfuscated_integer)
        obfuscated_integer.to_i(@@BASE) * @@IPRIME & @@MAXID
      end

      def self.aes_encrypt(message, password)
        aes = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
        aes.encrypt
        aes.key = OpenSSL::Digest::SHA256.new(password).digest
        Base64.encode64 aes.update(message.to_s.strip) + aes.final
      end

      def self.aes_decrypt(message, password)
        aes = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
        aes.decrypt
        aes.key = OpenSSL::Digest::SHA256.new(password).digest
        aes.update(Base64.decode64(message.to_s.strip)) + aes.final
      end

    end #cryptography
  end #crypto

end #dw
