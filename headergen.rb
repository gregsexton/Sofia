#!/usr/bin/ruby
require 'date'

$header = "//
// Copyright #{Date.today.year} Greg Sexton
//
// This file is part of Sofia.
//
// Sofia is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Sofia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with Sofia.  If not, see <http://www.gnu.org/licenses/>.
//

"
$exceptions = %w(GHUnitTestMain.m
		 GTMBase64.h
		 GTMBase64.m
		 GTMDefines.h
		 GTMGarbageCollection.h
		 GTMNSString+URLArguments.h
		 GTMNSString+URLArguments.m
		 MBPreferencesController.h
		 MBPreferencesController.m
		 RegexKitLite.h
		 RegexKitLite.m
		 SignedAwsSearchRequest.h
		 SignedAwsSearchRequest.m
		 ImageAndTextCell.h
		 ImageAndTextCell.m)

def removeCurrentHeader(buffer)
    returnBuffer = ""
    headerEnded = false #simple flag

    buffer.each_line{|line|
	if not headerEnded
	    next if line =~ /^\/\/.*$/
	    if line =~ /^\s*$/
		headerEnded = true
		next
	    end
	else
	    returnBuffer = returnBuffer + line
	end

    }
    return returnBuffer
end

def generateFileSpecificHeader(file)
    return "//\n// " + file + "\n" + $header
end



Dir["*.[hm]"].each{|file|
    next if $exceptions.include?(file)

    buffer = File.read(file)

    f = File.open(file, "w")

    f.puts(generateFileSpecificHeader(file))
    f.puts(removeCurrentHeader(buffer))

    f.close
}

