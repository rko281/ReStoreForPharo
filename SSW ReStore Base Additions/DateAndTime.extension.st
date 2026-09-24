Extension { #name : 'DateAndTime' }

{ #category : '*SSW ReStore Base Additions' }
DateAndTime class >> timezoneAware [

	^SSWDBDateAndTimeTimezoneAware new
]

{ #category : '*SSW ReStore Base Additions' }
DateAndTime class >> timezoneAwareWithResolution: anInteger [

	^self timezoneAware
		resolution: anInteger;
		yourself
]

{ #category : '*SSW ReStore Base Additions' }
DateAndTime class >> withMillisecondResolution [

	^SSWDBDateAndTimeWithResolution new
		beMillisecondResolution
		yourself
]

{ #category : '*SSW ReStore Base Additions' }
DateAndTime class >> withResolution: anInteger [

	^SSWDBDateAndTimeWithResolution new
		resolution: anInteger
		yourself
]
