#!/usr/bin/env ruby

require 'json'

class AppError < StandardError
end

class AppInternalError < StandardError
end

def write_error(klass, message)
  if ENV.has_key?("DX_JOB_ID")
    File.open(ENV["HOME"] + "/job_error.json", "w") do |file|
      file.write ({error: {type: klass, message: message}}).to_json
    end
  else
    STDERR.puts message
  end
  exit(1)
end

begin
  list = []
  ARGF.each_line do |line|
    line.chomp!
    list << line
  end

  samples = {}
  sample_order = []
  list.each_with_index do |fname, i|
    sample = fname
    if fname =~ /^(.+)\.bam$/
      sample = $1
    end
    if sample =~ /^(.+)\.replicate-(\d+)$/
      sample = $1
      replicate = $2.to_i
      if samples.has_key?(sample) && samples[sample].has_key?(replicate)
        raise AppError, "Found multiple files called '#{fname}' for replicate '#{replicate}' of sample '#{sample}'"
      end
      if samples.has_key?(sample) && samples[sample].has_key?(-1)
        raise AppError, "Sample '#{sample}' includes both replicate and non-replicate files"
      end
    else
      replicate = -1
      if samples.has_key?(sample) && samples[sample].has_key?(-1)
        raise AppError, "Found multiple files called '#{fname}' for sample '#{sample}'"
      end
      if samples.has_key?(sample)
        raise AppError, "Sample '#{sample}' includes both replicate and non-replicate files"
      end
    end
    samples[sample] ||= {}
    samples[sample][replicate] = i
    sample_order << sample unless sample_order.include?(sample)
  end

  unless samples.size >= 2
    raise AppError, "At least two samples (with or without replicates) are required to run this app"
  end

  inputs = sample_order.map { |sample|
    samples[sample].keys.sort.map { |replicate|
      "input-" + samples[sample][replicate].to_s + ".bam"
    }.join(",")
  }.join(" ")

  labels = sample_order.map { |sample|
    s = sample.gsub(/,/, "")
    if s == ""
      s = "sample-" + Time.now.to_i
      sleep 1
    end
    s
  }.join(",")

  puts ({"inputs" => inputs, "labels" => labels}.to_json)

rescue AppError => e
  write_error("AppError", e.message)
rescue AppInternalError => e
  write_error("AppInternalError", e.message)
end
