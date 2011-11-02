module DW
  # Set of classes for managing image processing related
  # functionality

  module ImageProcessing

    # Static methods for basic image manipulation
    #
    class ImageUtilities

      # Crop the image using the crop size hash given
      #
      def self.crop_with_image(image,crop_size)
        image.crop("#{crop_size[:width]}x#{crop_size[:height]}"\
                    "+#{crop_size[:x]}+#{crop_size[:y]}")
        image
      end
      
      # Resizes the image while keeping its dimensions 
      #
      def self.reduce_to_with_image(image,optimal_size)
        if image[:width] > image[:height]
          if image[:width] > optimal_size[:width]
            image.resize(
              "#{optimal_size[:width]}x"\
              "#{(image[:height]*optimal_size[:width])/image[:width]}"
              )
          end
        else
          if image[:height] > optimal_size[:height]
            image.resize(
              "#{(image[:width]*optimal_size[:height])/image[:height]}"
              )
          end
        end
        
        image
      end
      
      # Creates an image object from the blob and calls
      # square_thumbnail_with_image
      # blob - raw contents of the image file
      # thumbnail_size - side of desired square thumbnail 
      # returns a blob
      def self.square_thumbnail_with_blob(blob,thumbnail_size)
        image = MiniMagick::Image.from_blob(blob)
        ImageUtilities.square_thumbnail_with_image(image,thumbnail_size).to_blob
      end

      # Creates a square thumbnail from the given image by shaving off
      # extra content from the dominating dimension
      # image - MiniMagick image object 
      # thumbnail_size - side of the desired square thumbnail 
      # returns a blob
      #
      def self.square_thumbnail_with_image(image,thumbnail_size)
        if image[:width] > image[:height]
          image.shave("#{(image[:width]-image[:height])/2}x0+0+0")
        elsif image[:height] > image[:width]
          image.shave("0x#{(image[:height]-image[:width])/2}+0+0")
        end
        
        if image[:width] > thumbnail_size
          image.resize("#{thumbnail_size}x#{thumbnail_size}")
        end

        image
      end

      # Rotate the image object by the given angle
      #
      def self.rotate_image(image,angle)
        image.rotate "#{angle}>"
      end

      # Creates an image object from the given blob and calls
      # composite image on image
      # blob - raw contents of the image file
      # overlay_path - path of the image to be composited
      # returns a blob of the composited image
      #
      def self.composite_image_on_blob(blob,overlay_path)
        image = MiniMagick::Image.from_blob(blob)
        ImageUtilities.composite_image_on_image(image,overlay_path)
      end

      # Overlays the image at the overlay_path onto the image
      # provided
      # image - MiniMagick image object
      # overlay_path - path of the image to be composited
      # returns a blob of the composited image
      def self.composite_image_on_image(image,overlay_path)
        overlay = MiniMagick::Image.open(overlay_path)
        result = image.composite(overlay,"jpg"){|c| c.gravity "center"}
        result.to_blob
      end

    end #class


  end #module

end #dw
