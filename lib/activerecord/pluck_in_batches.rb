require "activerecord/pluck_in_batches/version"
require "active_record/relation"

module InBatches
  def in_batches(of: 1000)
    batches = (count / batch_size.to_f).ceil

    relation = reorder("#{quoted_table_name}.#{quoted_primary_key} ASC").limit(batch_size)

    if block_given?
      batches.times do |i|
        yield relation.offset(i * batch_size)
      end
    else
      batches.times.map { |i| relation.offset(i * batch_size) }
    end
  end
end

module PluckInBatches
  def pluck_in_batches(*args, &block)
    options = args.extract_options!
    in_batches(**options) do |batch|
      batch.pluck(*args).each(&block)
    end
  end
end

ActiveRecord::Relation.send :include, InBatches if Rails.version < "5.0.0"
ActiveRecord::Relation.send :include, PluckInBatches
