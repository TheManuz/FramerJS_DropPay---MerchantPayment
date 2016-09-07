# Project Info
# This info is presented in a widget when you share.
# http://framerjs.com/docs/#info.info

Framer.Info =
	title: "DropPay - Merchant selling interaction"
	author: "Emanuele Salamone"
	twitter: ""
	description: ""


#Define custom device
Framer.DeviceView.Devices["custom"] =
	"deviceType": "phone"
	"screenWidth": 720
	"screenHeight": 1280
	"deviceImage": "images/nexus5_for_framer.png"
	"deviceImageWidth": 1211
	"deviceImageHeight": 1687
	
# Set custom device
Framer.Device.deviceType = "custom"

Framer.Device.background.backgroundColor = "rgb(242,242,242)"
Framer.Device.contentScale = 1
Framer.Device.deviceScale = 0.5

# Import file "DropPay Mockups - Android" (sizes and positions are scaled 1:3)
sketch = Framer.Importer.load("imported/DropPay Mockups - Android@2x")

Utils.globalLayers(sketch)

#Module Imports
TextLayer = require 'TextLayer'

ViewController = require 'ViewController'

Pointer = require 'Pointer'

AndroidRipple = require 'androidRipple'


#Init amount textlayer
amount = vendita1_textfield_amount.convertToTextLayer()
amount.fontFamily = "Roboto"
amount.fontWeight = 500 #Medium weight 
amount.autoSize = true

amountRecapLabel = vendita2_label_amount.convertToTextLayer()
amountRecapLabel.autoSize = true

currency = vendita1_label_currency

typeAmount = (value) ->
	if (amount.text is 0)
		amount.text = value
	else
		commaIndex = amount.text.indexOf(",")
		if (commaIndex == -1 and value isnt ",")
			if  (amount.text.length <4)
				amount.text += value
		else
			if (amount.text.length < commaIndex + 3 or value is ",")
				amount.text += value
	amount.centerX()
	currency.x = amount.x + amount.width
	amountRecapLabel.text = amount.text+" €"
	
deleteChar = () ->
	if (amount.text.length > 1)
		amount.text = amount.text.slice(0, -1)
	else
		amount.text = "0"
	amount.centerX()
	currency.x = amount.x + amount.width
	amountRecapLabel.text = amount.text+" €"
	
amount.text = "0"
amountRecapLabel.text = amount.text+" €"

#Keypad initialization

merchantBlue = "#18A8F0"

#Numeric keys callback
for key in numeric_keypad.children
	do (key) ->
		key.onClick ->
			if (amount.text.length is 1 and amount.text.charAt(0) is "0")
				amount.text = key.name.charAt(1)
			else
				typeAmount(key.name.charAt(1))
		key.on(Events.Click, AndroidRipple.Ripple)
		key.rippleColor = merchantBlue

comma.on(Events.Click, AndroidRipple.Ripple)
comma.rippleColor = merchantBlue
comma.onClick ->
	if (amount.text.indexOf(",") == -1)
		typeAmount(",")
	
del.on(Events.Click, AndroidRipple.Ripple)
del.rippleColor = merchantBlue
del.onClick ->
	deleteChar()

#ViewController initializing
Views = new ViewController
    initialView: vendita1

navbar.bringToFront()

vendita1_button.onClick -> Views.androidPushIn(vendita2)

#Schermata 2 setup
for key in vendita2_bottomsheet_grid.children
	do (key) ->
		key.onClick -> Views.zoomIn(vendita3)
		
vendita2_back.onClick ->
	Views.back()

descriptionInput = vendita2_label_description.convertToTextLayer()

descriptionHint = descriptionInput.copy()
descriptionHint.parent = vendita2_fields

descriptionInput.text = ""
descriptionInput.on(Events.Click, AndroidRipple.Ripple)
descriptionInput.rippleColor = merchantBlue
descriptionInput.color = "black"
descriptionInput.width = 272*2
descriptionInput.height = 48*2
descriptionInput.contentEditable = true
descriptionInput.setup = true

descriptionInput.addListener "input" , () ->
	if (descriptionInput.text.length is 0)
		descriptionHint.visible = true
	else
		descriptionHint.visible = false

#Schermata 3 setup
circlePulse = null

infoLabel = vendita3_label_info.convertToTextLayer()
infoLabel.fontWeight = 500 #Medium weight 
infoLabel.autoSize = true

circularMaskDiameter = Math.pow(Math.pow(Framer.Device.screen.width, 2)+Math.pow(Framer.Device.screen.height, 2), 0.5)

greenScreen = new Layer
	originX: 0.5
	originY: 0.5 
	width: circularMaskDiameter
	height: circularMaskDiameter
	backgroundColor: "rgb(126,211,33)"
	parent: vendita3
	borderRadius: "50%"
	clip: true
greenScreen.placeBefore(vendita3_QRcode)
greenScreen.states.add
	hidden:
		x: Framer.Device.screen.width*0.5
		y: Framer.Device.screen.height*0.5
		width: 0
		height: 0
	grown:
		x: (Framer.Device.screen.width-circularMaskDiameter)*0.5
		y: (Framer.Device.screen.height-circularMaskDiameter)*0.5
		width: circularMaskDiameter
		height: circularMaskDiameter

vendita3_check.setParent(greenScreen)
vendita3_check.center()

vendita3_check.states.add
	hidden:
		scale: 0
		x: -vendita3_check.width/2
		y: -vendita3_check.height/2
		
for layer in [vendita3_QRcode, infoLabel]
	do (layer) ->
		layer.states.add
			hidden:
				scale: 0
				opacity: 0
			
Views.onViewWillSwitch (oldView, newView) ->
	if newView is vendita3	
		greenScreen.states.switchInstant("hidden")
		vendita3_check.states.switchInstant("hidden")
		vendita3_QRcode.states.switchInstant("hidden")
		infoLabel.states.switchInstant("default")
		vendita3_QRcode.states.switch("default", curve: "bezier-curve", curveOptions: [0.0, 0.0, 0.2, 1], time: 0.375)
		Utils.delay 4, ->
			#vendita3_QRcode.states.switch("hidden", curve: "bezier-curve", curveOptions: [0.0, 0.0, 0.2, 1], time: 0.375)								
			vendita3_check.states.switch("default", curve: "bezier-curve", curveOptions: [0.0, 0.0, 0.2, 1], time: 0.425)
			greenScreen.states.switch("grown", curve: "bezier-curve", curveOptions: [0.0, 0.0, 0.2, 1], time: 0.425)
			infoLabel.text = "Pagamento effettuato"
			infoLabel.centerX()
			
Views.onViewDidSwitch (oldView, newView) ->
	if newView is vendita3
		circlePulse = new Layer
			name: "circlePulse"
			x: (Framer.Device.screen.width-circularMaskDiameter)*0.5
			y: (Framer.Device.screen.height-circularMaskDiameter)*0.5
			width: circularMaskDiameter
			height: circularMaskDiameter
			borderRadius: "50%"
			backgroundColor: "rgba(255,255,255,1)"
			opacity: 1
			superLayer: vendita3
			scale: 0.44
		circlePulse.placeBehind(vendita3_QRcode)
		circlePulse.animate
			properties:
				scale: 1
				opacity: 0
			curve: "bezier-curve"
			curveOptions: [0.0, 0.0, 0.2, 1]
			repeat: 1
			time: 2
			
vendita3_close.onClick ->
	Views.back()
	circlePulse.destroy()
