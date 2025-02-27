Extension { #name : 'DateAndTime' }

{ #category : '*SSW ReStore Base Additions' }
DateAndTime class >> withMillisecondResolution [

	^SSWDBDateAndTimeWithResolution new
		beMillisecondResolution
		yourself
]
