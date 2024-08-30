Class {
	#name : #GtOllamaChat,
	#superclass : #GtLlmChat,
	#instVars : [
		'assistantWorking'
	],
	#category : #'Gt4Ollama-Chat'
}

{ #category : #'as yet unclassified' }
GtOllamaChat >> asMarkdown [
	| stream |
	stream := WriteStream on: String new.
	self asMarkdown: stream.
	^ stream contents
]

{ #category : #'as yet unclassified' }
GtOllamaChat >> asMarkdown: stream [
	self messages reversed
		do: [ :msg | 
			stream cr
				nextPutAll: '# ';
				nextPutAll: msg role asString;
				cr;
				cr;
				nextPutAll: msg content asString;
				cr;
				cr ]
]

{ #category : #'as yet unclassified' }
GtOllamaChat >> gtTextFor: aView [
	<gtView>
	^ aView text
		title: 'Markdown';
		priority: 4;
		text: [ self asMarkdown ];
		updateWhen: GtOpenAIThreadRunAnnouncement in: self announcer;
		actionUpdateButton
]

{ #category : #accessing }
GtOllamaChat >> gtTriggerAssistantActionFor: anAction [
	<gtAction>
	^ anAction button
		priority: 1;
		tooltip: 'Trigger';
		icon: BrGlamorousVectorIcons refresh;
		action: [ self triggerAssistant ]
]

{ #category : #accessing }
GtOllamaChat >> initialize [
	super initialize.

	assistantWorking := false
]

{ #category : #accessing }
GtOllamaChat >> initializeClient [
	client := GtOllamaClient new
]

{ #category : #accessing }
GtOllamaChat >> initializeMessages [
	messages := GtLlmMessagesGroup new
]

{ #category : #accessing }
GtOllamaChat >> sendMessage: aMessage [
	messages
		addFirst: (GtLlmUserMessage new
				content: aMessage;
				chat: self).
	self triggerAssistant
]

{ #category : #accessing }
GtOllamaChat >> status [
	^ assistantWorking
		ifTrue: [ GtOpenAIAssistantChatWorkingStatus new ]
		ifFalse: [ GtOpenAIAssistantChatReadyStatus new ]
]

{ #category : #accessing }
GtOllamaChat >> triggerAssistant [
	| result |
	assistantWorking := true.

	self announcer announce: (GtOpenAIThreadRunStartedAnnouncement new run: self).

	result := client
			completeChatWithModel: self model
			andMessages: messages reversed.

	self addMessage: (result asLlmMessage chat: self).

	assistantWorking := false
]
