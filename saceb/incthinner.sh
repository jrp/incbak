#! /bin/bash
## thins out inc backups in an exponential backof fasion
## uses ratio of backup before and after with the current time to calculate backup importance.
## authur JR Peterson
## date 2010-02-12

#Thinner:

	#called by snapper or manually

#parse arguments to get the following:
set baklist=/archive/testbak/


#constants



#set up logging
	
	
	
#repeat

	#check DF and classify by colour, and note this
	
		#capacity-green: over safe value: all good, note this, exit.

		#capacity-amber: under safe value: is ok -- having to thin data though.

		#capacity-red: under critical value: flag error, then run as per normal.
	set capacity-colour=amber ##interim
	
	
	#for each directory that has the right format of name
	set lst=`ls baklist`
	for curr in lst do
		#call it "curr"

		#parse date
			#use substring stuff to separate elements
		
		
		
		
		old=`date -d"20100212" +%s`
		new=`date +%s`
		echo $(( ${new} - ${old} ))
		out=$(($new - $old))

		
		#run filters like is newer than 1 week

		#run filter for whether the name has a "keep" in it

		#parse it's name to get date

		#traverse folders to find greatest file that's less than -- call this "before"

		#traverse folders to find least file that's greater than -- call this "after"

		#if either of the above are blank, abort: is first or last backup

		#do calculation,

		#if this is the smallest ratio encountered so far, store and "favourite"

	#if ratio smaller than "safe-ratio"

		#note ratio, age and name

		#remove backup

	#elif

		#if capacity-red and ratio smaller than "grudingly-safe-ratio"

			#error grudgingly-safe deletion, DF, ratio, age,name

			#delete backup

		#else

			#error aborted-unsafe, DF, ratio, age,name

			#abort

#exit

