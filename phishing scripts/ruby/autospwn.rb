#!/usr/bin/env ruby

require 'rubygems'
require 'net/smtp'
if RUBY_VERSION < "1.8.7"
  require 'smtp_tls'
end
require 'tmail'
require 'optparse'


  class OptparseExample

    def self.parse(args)

       options = {}

        OptionParser.new do |opts|
          opts.banner = (
	          "Usage: autospwn.rb -u gmailuname -p gmailpassword -f 'fake name <fake@fake.com>' -l list.txt -s 'Check this out dude' -b body.txt"
          )
          options[:banner] = opts.banner
          
          opts.separator ""
          opts.separator "Mandatory options:"
          
          opts.on("-p", "--password PASSWORD", "Enter your e-mail password") do |p|
          options[:password] = p
          end
          
          
          opts.on("-u", "--username USERNAME", "Enter your e-mail username") do |u|
          options[:username] = u
          end
          
          opts.on("-f", "--from FROM", "Enter the fake name you would like to display") do |f|
          options[:from] = f
          end
 	        
          opts.on("-l", "--list list.txt", "Enter the location and filename containing list of recipient e-mail addresses") do |l|
          options[:list] = l
          end
          
          opts.on("-t", "--to TO", "Omit the -l or --list option in favor of this option if you prefer single recipient address") do |t|
          options[:to] = t
          end
          
          opts.on("-s", "--subject SUBJECT",   "This will be the subject of the e-mail") do |s|
          options[:subject] = s
          end
          
	        opts.on("-b", "--body body.txt", 'Example of misleading link: <a target="_blank" href="http://www.realurl.com">http://www.fakeurl.com</a>') do |b|
          options[:body] = b
          end
          
          opts.separator ""
          opts.separator "Informational options:"
          
          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          opts.on_tail("-h", "--help", "Displays this screen") do
          puts opts
          exit
          end
          
          opts.on_tail("-v","--version", "Show version") do
          puts "Autospwn Version 0.1a"
          exit
          end

   
		      begin
			      opts.parse!(args)
		      rescue OptionParser::InvalidOption
			      puts "Invalid option, try -h for usage"
		      rescue OptionParser::MissingArgument
            puts opts.banner
          rescue TypeError
			      puts "You may have incorrectly spelled the filename or ommitted it from -l or -b entirely"	
		        exit
		      end
		        return options
	        end
	      end
      end

  @options = OptparseExample.parse(ARGV)

  #SMTP Server Details
  smtp_server = 'smtp.gmail.com'
  smtp_port = 587
  smtp_user = @options[:username]
  smtp_pass = @options[:password]
  smtp_authtype = :plain
  
  #Email Details -- Self Explanatory
  mail_from = @options[:from] #'cktricky <fake@email.com>'
  mail_subject = @options[:subject] #'Dude you have to check this out'

  
  begin
    body_file = File.open(@options[:body], "r")
    file_lines = body_file.readlines()
    body_file.close()
    body = file_lines.to_s.split("\n\n")
    mail_body = body #'<a target="_blank" href="http://www.google.com">http://www.metasploit.com</a>'
  rescue TypeError 
    puts "Something wasn't type correctly #{@options[:banner]}"
  end

def starting
  file = File.open(@options[:list]) if @options.has_key?(:list) 
  file = @options[:to] if @options[:to]
  return file
end

  exit if starting.nil?
  starting.each_line do |send|

    print("\e[1m\e[34m[*]\e[0m The following pwnie is receiving your e-mail: #{send}")
		
    mail_bcc = send.gsub(/\n/,'')
    mail = TMail::Mail.new
    mail.from = mail_from
    mail.date = Time.now
    mail.mime_version = '1.0'
    mail.content_type= 'text/html'
    mail.subject = mail_subject
    mail.body = mail_body
        
    smtp = Net::SMTP.new(smtp_server, smtp_port)
    smtp.enable_starttls
    smtp.start( 'localhost.localdomain', smtp_user, smtp_pass, smtp_authtype ) do |smtp|
      smtp.send_message( mail.to_s, mail.from, mail_bcc)
    end
end	

print("\n\e[1m\e[32m[+]\e[0m I'm done\n")
