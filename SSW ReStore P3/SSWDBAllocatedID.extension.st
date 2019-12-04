Extension { #name : #SSWDBAllocatedID }

{ #category : #'*SSW ReStore P3' }
SSWDBAllocatedID >> p3PrintUsing: delegate on: stream [
	
	self asInteger p3PrintUsing: delegate on: stream
]
