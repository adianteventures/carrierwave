# encoding: utf-8

module CarrierWave
  module Uploader
    module Remove
      extend ActiveSupport::Concern

      include CarrierWave::Uploader::Callbacks

      ##
      # Removes the file and reset it
      #
      def remove!
        with_callbacks(:remove) do
          
          # make several attempts to remove the file and also set a timeout per attempt
          total_attempts = 5
          timeout_s = 30
          
          total_attempts.times do |attempt|
            begin
              Timeout::timeout(timeout_s) do
                @file.delete if @file
              end
              
              # if we reach this point, removal was successfull: break the attempt-loop
              break
              
            rescue Exception => e
              puts "CarrierWave::Uploader::Remove - RETRY! attempt=#{attempt}. ERROR: #{e.message}"
              if (attempt >= (total_attempts-1))
                # if last retry also failed, raise exception
                raise e
              end
            end
          end
          
          @file = nil
          @cache_id = nil
        end
      end

    end # Remove
  end # Uploader
end # CarrierWave
