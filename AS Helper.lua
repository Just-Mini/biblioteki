script_name('AS Helper')
script_description('/ash')
script_author('JustMini')

require "lib.moonloader"
local dlstatus = require "moonloader".download_status
local inicfg = require "inicfg"
local vkeys = require "vkeys"
local imguicheck, imgui = pcall(require, "imgui")
local sampevcheck, sampev = pcall(require, "lib.samp.events")
local encodingcheck, encoding = pcall(require, "encoding")
local facheck, fa = pcall(require, "fAwesome5")

local configuration = inicfg.load({
	main_settings = {
		myrankint = 0,
		myrank = "",
		myname = '',
		myaccent = '',
		useservername = true,
		useaccent = false,
		avtoprice = 5000,
		motoprice = 10000,
		ribaprice = 30000,
		lodkaprice = 30000,
		gunaprice = 50000,
		huntprice = 100000,
		kladprice = 200000,
		usefastmenu = 'E',
		createmarker = false,
		dorponcmd = true,
		replacechat = true,
		gender = 0
	},
	my_stats = {
		avto = 0,
		moto = 0,
		riba = 0,
		lodka = 0,
		guns = 0,
		hunt = 0,
		klad = 0
	},
	binder_settings = {
		totalslots = 50
	},
	BindsName = {},
	BindsDelay = {},
	BindsType = {},
	BindsAction = {},
	BindsCmd = {},
	BindsKeys = {}
}, "AS Helper")

local cmdhelp 				= 'ash'
local cmdbind 				= "ashbind"
local cmdcmds 				= "ashcmds"
local cmdupdate 			= "ashupd"
local cmdstats 				= "ashstats"

local cd 					= 2000

local log = {}
local emptykey1 = {}
local emptykey2 = {}

local cansell 				= false
local inprocess 			= false
local devmaxrankp			= false
local NoErrors				= false
local scriptvernumb 		= 16

if imguicheck and encodingcheck then
	u8 						= encoding.UTF8
	encoding.default 		= 'CP1251'

	imgui_settings 			= imgui.ImBool(false)
	imgui_fm 				= imgui.ImBool(false)
	imgui_sobes				= imgui.ImBool(false)
	imgui_binder 			= imgui.ImBool(false)
	imgui_stats				= imgui.ImBool(false)

	useaccent 				= imgui.ImBool(configuration.main_settings.useaccent)
	createmarker 			= imgui.ImBool(configuration.main_settings.createmarker)
	useservername 			= imgui.ImBool(configuration.main_settings.useservername)
	dorponcmd				= imgui.ImBool(configuration.main_settings.dorponcmd)
	replacechat				= imgui.ImBool(configuration.main_settings.replacechat)
	myname 					= imgui.ImBuffer(configuration.main_settings.myname, 256)
	myaccent 				= imgui.ImBuffer(configuration.main_settings.myaccent, 256)

	ComboBox_select 		= imgui.ImInt(0)
	ComboBox_arr 			= {u8"����",u8"����",u8"�����������",u8"��������",u8"������",u8"�����",u8"��������"}
	avtoprice 				= imgui.ImBuffer(tostring(configuration.main_settings.avtoprice), 7)
	motoprice 				= imgui.ImBuffer(tostring(configuration.main_settings.motoprice), 7)
	ribaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.ribaprice), 7)
	lodkaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.lodkaprice), 7)
	gunaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.gunaprice), 7)
	huntprice 				= imgui.ImBuffer(tostring(configuration.main_settings.huntprice), 7)
	kladprice				= imgui.ImBuffer(tostring(configuration.main_settings.kladprice), 7)

	expelbuff 				= imgui.ImBuffer(200)

	uninvitebuf 			= imgui.ImBuffer(256)
	blacklistbuf 			= imgui.ImBuffer(256)
	uninvitebox 			= imgui.ImBool(false)

	blacklistbuff 			= imgui.ImBuffer(256)

	fwarnbuff 				= imgui.ImBuffer(256)

	fmutebuff 				= imgui.ImBuffer(256)
	fmuteint 				= imgui.ImInt(0)

	binderbuff 				= imgui.ImBuffer(4096)
	bindername 				= imgui.ImBuffer(40)
	binderdelay 			= imgui.ImBuffer(7)
	bindertype 				= imgui.ImInt(0)
	bindercmd 				= imgui.ImBuffer(15)

	windowtype				= imgui.ImInt(0)
	sobesetap				= imgui.ImInt(0)

	waitingaccept 			= false
	getmyrank 				= false
	mcvalue 				= true
	passvalue 				= true
	skiporcancel			= true

	Ranks_select 			= imgui.ImInt(0)
	Ranks_arr 				= {u8"[1] �����",u8"[2] �����������",u8"[3] �������",u8"[4] ��. ����������",u8"[5] ����������",u8"[6] ��������",u8"[7] ��. ��������",u8"[8] �������� ���������",u8"[9] ��������"}

	gender 					= imgui.ImInt(configuration.main_settings.gender)
	gender_arr 				= {u8"�������",u8"�������"}

	sobesdecline_select 	= imgui.ImInt(0)
	sobesdecline_arr 		= {u8"������ ��",u8"�� ���� ��",u8"������ ����������",u8"������ �� �������",u8"������"}

	--���� �� madrasso: https://www.blast.hk/threads/25442/#post-310168
	imgui.SwitchContext()
	local style 						= imgui.GetStyle()
	local colors 						= style.Colors
	local clr 							= imgui.Col
	local ImVec4 						= imgui.ImVec4
	local ImVec2 						= imgui.ImVec2

	style.WindowTitleAlign 				= ImVec2(0.5, 0.5)
	style.WindowPadding 				= ImVec2(15, 15)
	style.WindowRounding 				= 6.0
	style.FramePadding 					= ImVec2(5, 5)
	style.FrameRounding 				= 4.0
	style.ItemSpacing 					= ImVec2(12, 8)
	style.ItemInnerSpacing 				= ImVec2(8, 6)
	style.IndentSpacing 				= 25.0
	style.ScrollbarSize 				= 15.0
	style.ScrollbarRounding 			= 9.0
	style.GrabMinSize 					= 5.0
	style.GrabRounding 					= 3.0

	colors[clr.Text] 					= ImVec4(0.80, 0.80, 0.83, 1.00)
	colors[clr.TextDisabled] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] 				= ImVec4(0.06, 0.05, 0.07, 0.95)
	colors[clr.ChildWindowBg] 			= ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.PopupBg] 				= ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] 					= ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] 			= ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] 				= ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] 				= ImVec4(0.76, 0.31, 0.00, 1.00)
	colors[clr.TitleBgCollapsed] 		= ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] 			= ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.MenuBarBg] 				= ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] 			= ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] 			= ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] 	= ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] 				= ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrab] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrabActive] 		= ImVec4(1.00, 0.42, 0.00, 1.00)
	colors[clr.Button] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
	colors[clr.ButtonHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] 					= ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive] 			= ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ResizeGrip] 				= ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] 		= ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] 		= ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] 			= ImVec4(0.914	, 0.439, 0, 1.00)
	colors[clr.CloseButtonHovered] 		= ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] 		= ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] 				= ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered]		= ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] 			= ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] 	= ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] 			= ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] 	= ImVec4(1.00, 0.98, 0.95, 0.73)

	function imgui.LockedButton(text, size)
		local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		imgui.Button(text, size)
		imgui.PopStyleColor(4)
	end

	function imgui.GreenButton(text, size)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
		local button = imgui.Button(text, size)
		imgui.PopStyleColor(3)
		return button
	end

	function imgui.Hint(text, delay, action)
		if imgui.IsItemHovered() then
			if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
			local alpha = (os.clock() - go_hint) * 5
			if os.clock() >= go_hint then
				imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
				imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
					imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.11, 0.11, 0.11, 0.80))
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(450)
						imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'���������').x) / 2)
						imgui.TextColored(imgui.ImVec4(1.0, 1.0, 1.0, 1.0 ),u8'���������')
						imgui.TextColored(imgui.ImVec4(1.0, 1.0, 1.0, 1.0 ),text)
						if action ~= nil then
							imgui.Text('\n '..action)
						end
						if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					imgui.PopStyleColor()
				imgui.PopStyleVar(2)
			end
		end
	end

	local fa_glyph_ranges	= imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
	function imgui.BeforeDrawFrame()
		if fa_font == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = true
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
		end
	end

	function imgui.OnDrawFrame()
		local ScreenX, ScreenY = getScreenResolution()

		if imgui_fm.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"���� �������� ������� ["..fastmenuID.."]", imgui_fm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)

			if windowtype.v == 0 then -- ������� ����  ������� ����  ������� ����  ������� ����  ������� ����  ������� ����  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' ���������������� ������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1 then
							disableallimgui()
							hello()
						else
							ASHelperMessage("������ ������� �������� � 1-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_ALT..u8' �������� ����� ����', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1  then
							disableallimgui()
							pricelist()
						else
							ASHelperMessage("������ ������� �������� � 1-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' ������� �������� ������', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 3 then
						imgui.SetScrollY(0)
						ComboBox_select.v = 0
						windowtype.v = 1
					else
						ASHelperMessage("������ ������� �������� � 3-�� �����.")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_REPLY..u8' ������� �� ���������', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 5 then
						imgui.SetScrollY(0)
						windowtype.v = 2
						expelbuff.v = ""
					else
						ASHelperMessage("������ ������� �������� � 5-�� �����.")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_USER_PLUS..u8' ������� � �����������', imgui.ImVec2(285,30))
				if imgui.IsItemClicked(0) or imgui.IsItemClicked(1) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							if imgui.IsItemClicked(0) then
								disableallimgui()
								invite(tostring(fastmenuID))
							end
							if imgui.IsItemClicked(1) then
								disableallimgui()
								lua_thread.create(function ()
									sampSendChat('/do ����� �� �������� � �������.')
									wait(cd)
									sampSendChat('/me ������ ���� � ������ ����, {gender:������|�������} ������ ���� �� ��������')
									wait(cd)
									sampSendChat('/me {gender:�������|��������} ���� �������� ��������')
									wait(cd)
									sampSendChat('����� ����������! ���������� �� ������.')
									wait(cd)
									sampSendChat('�� ���� ����������� �� ������ ������������ �� ��. �������.')
									sampSendChat("/invite "..fastmenuID)
									waitingaccept = fastmenuID
								end)
							end
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.Hint(u8"��� ��� �������� �������� � �����������\n��� ��� �������� �� ��������� ������������",0)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_MINUS..u8' ������� �� �����������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype.v = 3
							uninvitebuf.v = ""
							blacklistbuf.v = ""
							uninvitebox.v = false
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' �������� ���������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							Ranks_select.v = 0
							windowtype.v = 4
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_SLASH..u8' ������� � ������ ������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype.v = 5
							blacklistbuff.v = ""
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER..u8' ������ �� ������� ������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							unblacklist(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FROWN..u8' ������ ������� ����������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fwarnbuff.v = ""
							windowtype.v = 6
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_SMILE..u8' ����� ������� ����������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							unfwarn(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' ������ ��� ����������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fmutebuff.v = ""
							fmuteint.v = 0
							windowtype.v = 7
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' ����� ��� ����������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							funmute(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("������ ������� �������� � 9-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'�������� ������ '..fa.ICON_FA_STAMP, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 5 then
							imgui.SetScrollY(0)
							windowtype.v = 8
						else
							ASHelperMessage("������ �������� �������� � 5-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������������� '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 5 then
							imgui.SetScrollY(0)
							passvalue = false
							mcvalue = false
							passverdict = ""
							mcverdict = ""
							sobesetap.v = 0
							sobesdecline_select.v = 0
							imgui_fm.v = false
							imgui_sobes.v = true
						else
							ASHelperMessage("������ �������� �������� � 5-�� �����.")
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
			end

			if windowtype.v == 8 then -- ��������� �����  ��������� �����  ��������� �����  ��������� �����  ��������� �����  ��������� �����  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������� ����� � ������ ���', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: 09:00 - 19:00")
						sampSendChat("�������� ����� ������� ����� � ������ ���.")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������� ����� � �������� ���', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: 10:00 - 18:00")
						sampSendChat("�������� ����� ������� ����� � �������� ���.")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������ ������ ������� ��� �������', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: �������")
						sampSendChat("����� ��������� �������� ��������� �� ������ ������� ������ ������ �������?")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������������� ����������', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: (3+) ������� - ����, (4+) ��.���������� - ����, (8+) ���. ��������� - �������")
						sampSendChat("� ����� ��������� ��������� ����� ����������, ��������� � �������?")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'��������� ��� �������', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: (5+) ����������")
						sampSendChat("�������, � ����� ��������� ��������� ����� ������?")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'����� ��� ��� ���������', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: 5 ����� �����������, �� ���� ��������� �������.")
						sampSendChat("����������� ���������� ����� ��� ��� ����������?")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'��� ����� ������������', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: c����������� - ��� ������� ������� ����� ������������, ������� �� ���������.")
						sampSendChat("��� �� ������ ������ �������� ����� '������������'?")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'��������� � ������ �����������', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("���������: �� ���������, �� �����, '���' � '�������'.")
						sampSendChat("����� ������, ����� ��������� ����������� � ������ ����������� ���������?")
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'��������', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat("����������, "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ")..", �� ����� �����!")
						disableallimgui()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SameLine()
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
    			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'��������', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat("����� ����, �� �� �� ������ ����� �����. �������� � ��������� � ��������� ���.")
						disableallimgui()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
		
			if windowtype.v == 1 then -- ������� ���  ������� ���  ������� ���  ������� ���  ������� ���  ������� ���  
				imgui.Text(u8"��������: ", imgui.ImVec2(75,30))
				imgui.SameLine()
				imgui.Combo(' ', ComboBox_select, ComboBox_arr, #ComboBox_arr)
				imgui.NewLine()
				if ComboBox_select.v == 0 then
					whichlic = "����"
				elseif ComboBox_select.v == 1 then
					whichlic = "����"
				elseif ComboBox_select.v == 2 then
					whichlic = "�����������"
				elseif ComboBox_select.v == 3 then
					whichlic = "��������"
				elseif ComboBox_select.v == 4 then
					whichlic = "������"
				elseif ComboBox_select.v == 5 then
					whichlic = "�����"
				elseif ComboBox_select.v == 6 then
					whichlic = "��������"
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������� �������� �� '..u8(whichlic), imgui.ImVec2(285,30)) then
					if not inprocess then
						selllic(tostring(fastmenuID.." "..whichlic))
						disableallimgui()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'�������� �� �����', imgui.ImVec2(285,30)) then
					if not inprocess then
						selllic(tostring(fastmenuID).." �����")
						disableallimgui()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
		
			if windowtype.v == 2 then -- EXPEL  EXPEL  EXPEL  EXPEL  EXPEL  EXPEL  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� expel:").x) / 2)
				imgui.Text(u8"������� expel:", imgui.ImVec2(75,30))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"     ",expelbuff)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) / 2)
				if imgui.Button(u8'������� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(250,30)) then
					if expelbuff.v == nil or expelbuff.v == "" then
						ASHelperMessage("������� ������� expel!")
					else
						expel(tostring(fastmenuID.." "..u8:decode(expelbuff.v)))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
		
			if windowtype.v == 3 then -- �������  �������  �������  �������  �������  �������  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� ����������:").x) / 2)
				imgui.Text(u8"������� ����������:", imgui.ImVec2(75,30))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"    ", uninvitebuf)
				if uninvitebox.v then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� ��:").x) / 2)
					imgui.Text(u8"������� ��:", imgui.ImVec2(75,30))
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
					imgui.InputText(u8" ", blacklistbuf)
				end
				imgui.Checkbox(u8"������� � ��", uninvitebox)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if uninvitebuf.v == nil or uninvitebuf.v == '' then
						ASHelperMessage("������� ������� ����������!")
					else
						if uninvitebox.v then
							if blacklistbuf.v == nil or blacklistbuf.v == '' then
								ASHelperMessage("������� ������� ��������� � ��!")
							else
								uninvite(fastmenuID.." 1")
								disableallimgui()
							end
						else
							uninvite(fastmenuID.." 0")
							disableallimgui()
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
		
			if windowtype.v == 4 then -- ���� ����  ���� ����  ���� ����  ���� ����  ���� ����  ���� ����  
				imgui.PushItemWidth(270)
				imgui.Combo(' ', Ranks_select, Ranks_arr, #Ranks_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
				if imgui.GreenButton(u8'�������� ���������� '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
					giverank(fastmenuID.." "..(Ranks_select.v+1))
					disableallimgui()
				end
				if imgui.Button(u8'�������� ���������� '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
					disableallimgui()
					lua_thread.create(function ()
						sampSendChat('/me {gender:�������|��������} ���')
						wait(cd)
						sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
						wait(cd)
						sampSendChat('/me {gender:������|�������} � ������� ������� ����������')
						wait(cd)
						sampSendChat('/me {gender:�������|��������} ���������� � ��������� ����������, ����� ���� {gender:�����������|�����������} ���������')
						wait(cd)
						sampSendChat('/do ���������� � ���������� ���� ��������.')
						sampSendChat("/giverank "..fastmenuID.." "..Ranks_select.v+1)
					end)
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
		
			if windowtype.v == 5 then -- ���� ��  ���� ��  ���� ��  ���� ��  ���� ��  ���� ��  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� ��������� � ��:").x) / 2)
				imgui.Text(u8"������� ��������� � ��:", imgui.ImVec2(75,30))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"                   ", blacklistbuff)
				imgui.NewLine()
				if imgui.Button(u8'������� � �� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if blacklistbuff.v == nil or blacklistbuff.v == '' then
						ASHelperMessage("������� ������� ��������� � ��!")
					else
						blacklist(fastmenuID.." "..u8:decode(blacklistbuff.v))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end

			if windowtype.v == 6 then -- �������  �������  �������  �������  �������  �������
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� ��������:").x) / 2)
				imgui.Text(u8"������� ��������:", imgui.ImVec2(75,30))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"", fwarnbuff)
				imgui.NewLine()
				if imgui.Button(u8'������ ������� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if fwarnbuff.v == nil or fwarnbuff.v == '' then
						ASHelperMessage("������� ������� ������ ��������!")
					else
						fwarn(fastmenuID.." "..u8:decode(fwarnbuff.v))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end

			if windowtype.v == 7 then -- ������ ���  ������ ���  ������ ���  ������ ���  ������ ���  ������ ���  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� ����:").x) / 2)
				imgui.Text(u8"������� ����:", imgui.ImVec2(75,30))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"         ", fmutebuff)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"����� ����:").x) / 2)
				imgui.Text(u8"����� ����:", imgui.ImVec2(75,30))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
				imgui.InputInt(u8" ", fmuteint)
				imgui.NewLine()
				if imgui.Button(u8'������ ��� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if fmutebuff.v == nil or fmutebuff.v == '' then
						ASHelperMessage("������� ������� ������ ����!")
					else
						if fmuteint.v == nil or fmuteint.v == '' or fmuteint.v == 0 or tostring(fmuteint.v):find("-") then
							ASHelperMessage("������� ���������� ����� ����!")
						else
							fmute(fastmenuID.." "..u8:decode(fmuteint.v).." "..u8:decode(fmutebuff.v))
							disableallimgui()
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
			imgui.End()
		end

		if imgui_sobes.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"���� �������� ������� ["..fastmenuID.."]", imgui_sobes, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)
			if sobesetap.v == 1 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"�������������: ���� 2").x) / 2)
				imgui.Text(u8"�������������: ���� 2")
				imgui.Separator()
				if not mcvalue then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"���.����� - �� ��������").x) / 2)
					imgui.Text(u8"���.����� - �� ��������", imgui.ImVec2(75,30))
				else
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"���.����� - �������� ("..mcverdict..")").x) / 2)
					imgui.Text(u8"���.����� - �������� ("..mcverdict..")", imgui.ImVec2(75,30))
				end
				if not passvalue then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� - �� �������").x) / 2)
					imgui.Text(u8"������� - �� �������", imgui.ImVec2(75,30))
				else
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"������� - ������� ("..passverdict..")").x) / 2)
					imgui.Text(u8"������� - ������� ("..passverdict..")", imgui.ImVec2(75,30))
				end
				if mcvalue and mcverdict == (u8"� �������") and passvalue and passverdict == (u8"� �������") then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'���������� >', imgui.ImVec2(285,30)) then
						sobesaccept1()
					end
				end
			end

			if sobesetap.v == 7 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"����������: ����������").x) / 2)
				imgui.Text(u8"�������������: ����������")
				imgui.Separator()
				imgui.PushItemWidth(270)
				imgui.Combo(" ",sobesdecline_select,sobesdecline_arr , #sobesdecline_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'���������', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobesetap.v = 0
						if sobesdecline_select.v == 0 then
							sobesdecline("����. �������������2")
						elseif sobesdecline_select.v == 1 then
							sobesdecline("����. �������������3")
						elseif sobesdecline_select.v == 2 then
							sobesdecline("����. �������������4")
						elseif sobesdecline_select.v == 3 then
							sobesdecline("����. �������������1")
						elseif sobesdecline_select.v == 4 then
							sobesdecline("����. �������������5")
						end
						disableallimgui()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.PopStyleColor(2)
			end

			if sobesetap.v == 0 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"�������������: ���� 1").x) / 2)
				imgui.Text(u8"�������������: ���� 1")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'����������������', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobes1()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'��������� ��������� >', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobes2()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
			end

			if sobesetap.v == 2 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"�������������: ���� 3").x) / 2)
				imgui.Text(u8"�������������: ���� 3")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'���������� ������� � ����.', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						else
							inprocess = true
							sampSendChat("���������� ������� � ����.")
							inprocess = false
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'������ ������� ������ ���?', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						else
							inprocess = true
							sampSendChat("������ �� ������� ������ ���?")
							inprocess = false
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8"�������� �� ��� � ������������ ��? >", imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						else
							inprocess = true
							sampSendChat("�������� �� ��� � ������������ ��? ���� ��, �� ���������� ���������")
							sampSendChat("/n �� - ����������� ������� [���������, �������������, ����]")
							lua_thread.create(function()
								wait(50)
								sobesetap.v = 3
							end)
							inprocess = false
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
			end

			if sobesetap.v == 3 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"�������������: �������").x) / 2)
				imgui.Text(u8"�������������: �������")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'�������', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobesaccept2()
						sobesetap.v = 0
						disableallimgui()
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'���������', imgui.ImVec2(285,30)) then
					if not inprocess then
						lastsobesetap = sobesetap.v
						sobesetap.v = 7
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.PopStyleColor(2)
			end
			if sobesetap.v ~= 3 and sobesetap.v ~= 7  then
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'���������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if mcvalue or passvalue then
							if mcverdict == (u8"����������������") then
								sobesdecline("����������������")
								disableallimgui()
							elseif mcverdict == (u8"�� ��������� ��������") then
								sobesdecline("�� ��������� ��������")
								disableallimgui()
							elseif passverdict == (u8"������ 3 ��� � �����") then
								sobesdecline("������ 3 ��� � �����")
								disableallimgui()
							elseif passverdict == (u8"�� ���������������") then
								sobesdecline("�� ���������������")
								disableallimgui()
							elseif passverdict == (u8"����� � �����������") then
								sobesdecline("����� � �����������")
								disableallimgui()
							elseif passverdict == (u8"��� � ���������") then
								sobesdecline("��� � ���������")
								disableallimgui()
							elseif passverdict == (u8"� �� ���������") then
								sobesdecline("� �� ���������")
								disableallimgui()
							else
								lastsobesetap = sobesetap.v
								sobesetap.v = 7
							end
						else
							lastsobesetap = sobesetap.v
							sobesetap.v = 7
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.PopStyleColor(2)
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'�����', imgui.ImVec2(137,30)) then
				if sobesetap.v == 7 then
					sobesetap.v = lastsobesetap
				elseif sobesetap.v ~= 0 then
					sobesetap.v = sobesetap.v - 1
				else
					imgui_sobes.v = false
					imgui_fm.v = true
					windowtype.v = 0
				end
			end
			imgui.SameLine()
			if sobesetap.v ~= 3 and sobesetap.v ~= 7 then
				if imgui.Button(u8'���������� ����', imgui.ImVec2(137,30)) then
					if not inprocess then
						sobesetap.v = sobesetap.v + 1
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
			end
			imgui.End()
		end

		if imgui_settings.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"��������� ASHelper", imgui_settings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if userset then
				if imgui.Button(fa.ICON_FA_USER_COG..u8' ��������� ������������ '..(fa.ICON_FA_CARET_DOWN), imgui.ImVec2(285,30)) then
					userset = not userset
				end
				if imgui.Checkbox(u8"������������ ��� ��� �� ����",useservername) then
					if configuration.main_settings.myname == '' then
						local result,myid = sampGetPlayerIdByCharHandle(playerPed)
						myname.v = string.gsub(sampGetPlayerNickname(myid), "_", " ")
						configuration.main_settings.myname = sampGetPlayerNickname(myid)
					end
					configuration.main_settings.useservername = useservername.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if not useservername.v then
					if imgui.InputText(u8" ", myname) then
						configuration.main_settings.myname = myname.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
				end
				if imgui.Checkbox(u8"������������ ������",useaccent) then
					configuration.main_settings.useaccent = useaccent.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if useaccent.v then
					imgui.PushItemWidth(150)
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 275))
					if imgui.InputText(u8"   ", myaccent) then
						configuration.main_settings.myaccent = myaccent.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"[").x) / 18)
					imgui.Text("[")
					imgui.SameLine()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"[").x) / 1.65)
					imgui.Text("]")
				end
				if imgui.Checkbox(u8"��������� ������ ��� ���������",createmarker) then
					if marker ~= nil then
						removeBlip(marker)
					end
					marker = nil
					oldtargettingped = 0
					configuration.main_settings.createmarker = createmarker.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if imgui.Checkbox(u8"�������� ��������� ����� ������", dorponcmd) then
					configuration.main_settings.dorponcmd = dorponcmd.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if imgui.Checkbox(u8"�������� ��������� ���������", replacechat) then
					configuration.main_settings.replacechat = replacechat.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if imgui.Button(u8'��������', imgui.ImVec2(85,25)) then
					getmyrank = true
					sampSendChat("/stats")
				end
				imgui.SameLine()
				imgui.Text(u8"��� ����: "..u8(configuration.main_settings.myrank).." ("..u8(configuration.main_settings.myrankint)..")")
				imgui.PushItemWidth(85)
				if imgui.Combo(u8"",gender, gender_arr, #gender_arr) then
					configuration.main_settings.gender = gender.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.Text(u8"��� ������")
			else
				if imgui.Button(fa.ICON_FA_USER_COG..u8' ��������� ������������ '..(fa.ICON_FA_CARET_LEFT), imgui.ImVec2(285,30)) then
					userset = not userset
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if licset then
				if imgui.Button(fa.ICON_FA_FILE_ALT..u8' ������� �������� '..(fa.ICON_FA_CARET_DOWN), imgui.ImVec2(285,30)) then
					licset = not licset
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"����", avtoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.avtoprice = avtoprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 29) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"����", motoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.motoprice = motoprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"�������", ribaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.ribaprice = ribaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"��������", lodkaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.lodkaprice = lodkaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"������", gunaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.gunaprice = gunaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 31) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"�����", huntprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.huntprice = huntprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"��������", kladprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.kladprice = kladprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
			else
				if imgui.Button(fa.ICON_FA_FILE_ALT..u8' ������� �������� '..(fa.ICON_FA_CARET_LEFT), imgui.ImVec2(285,30)) then
					licset = not licset
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if keysset then
				if imgui.Button(fa.ICON_FA_KEYBOARD..u8' ��������� ������� ������ '..(fa.ICON_FA_CARET_DOWN), imgui.ImVec2(285,30)) then
					keysset = not keysset
				end
				if imgui.Button(u8'��������', imgui.ImVec2(65,25)) then
					table.remove(log)
					getbindkey = true
					getbindkeys()
					configuration.main_settings.usefastmenu = ""
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SameLine()
				imgui.Text(u8"������ �����. ����: ��� + "..configuration.main_settings.usefastmenu,imgui.ImVec2(80,25))
				if getbindkey then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'������� ����� �������').x) / 2)
					imgui.Text(u8"������� ����� �������",imgui.ImVec2(80,25))
				end
				if imgui.Button(u8'������', imgui.ImVec2(65,25)) then
					binder()
				end
				imgui.SameLine()
				imgui.Text(u8"������� ��������� �������",imgui.ImVec2(80,25))
			else
				if imgui.Button(fa.ICON_FA_KEYBOARD..u8' ��������� ������� ������ '..(fa.ICON_FA_CARET_LEFT), imgui.ImVec2(285,30)) then
					keysset = not keysset
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if otherset then
				if imgui.Button(fa.ICON_FA_CIRCLE_NOTCH..u8' ��������� '..(fa.ICON_FA_CARET_DOWN), imgui.ImVec2(285,30)) then
					otherset = not otherset
				end
				if imgui.Button(u8'���a��', imgui.ImVec2(65,25)) then
					imgui_stats.v = not imgui_stats.v
				end
				imgui.SameLine()
				imgui.Text(u8"���������� ��������� ��������",imgui.ImVec2(80,25))
			else
				if imgui.Button(fa.ICON_FA_CIRCLE_NOTCH..u8' ��������� '..(fa.ICON_FA_CARET_LEFT), imgui.ImVec2(285,30)) then
					otherset = not otherset
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if scriptinfo then
				if imgui.Button(fa.ICON_FA_INFO_CIRCLE..u8' ���������� � ������� '..(fa.ICON_FA_CARET_DOWN), imgui.ImVec2(285,30)) then
					scriptinfo = not scriptinfo
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'���������: JustMini').x) / 2)
				imgui.Text(u8'���������: JustMini',imgui.ImVec2(70,20))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'��������� �������:').x) / 2)
				imgui.Text(u8'��������� �������:',imgui.ImVec2(70,20))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8
[[
Zody, madrasso, Royan_Millans,
Raymond, Cosmo, Alex_Liquid
]]
				).x) / 2)
				imgui.Text(u8
[[
Zody, madrasso, Royan_Millans,
Raymond, Cosmo, Alex_Liquid
]]
				,imgui.ImVec2(70,20))
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'������ 1.9').x) / 2)
				imgui.Text(u8'������ 1.9',imgui.ImVec2(70,20))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 210) / 2)
				if imgui.Button(u8'��������� ������� ����������', imgui.ImVec2(210,25)) then
					local checking = checkbibl()
					while not checking do
						wait(200)
					end
				end
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8
[[
���������� ������� �������� �� 2-�� ����;
��������� ��������� � �������;
�������� ������� �������������;
������� ����� ������� ��������� �����;
��������� ��� � �������������� ����������;
������ ������ �������������� ��� ��� ����.
]]
				).x) / 2)
				imgui.Text(u8
[[
���������� ������� �������� �� 2-�� ����;
��������� ��������� � �������;
�������� ������� �������������;
������� ����� ������� ��������� �����;
��������� ��� � �������������� ����������;
������ ������ �������������� ��� ��� ����.
]]
				,imgui.ImVec2(70,20))
			else
				if imgui.Button(fa.ICON_FA_INFO_CIRCLE..u8' ���������� � ������� '..(fa.ICON_FA_CARET_LEFT), imgui.ImVec2(285,30)) then
					scriptinfo = not scriptinfo
				end
			end
			imgui.End()
		end

		if imgui_binder.v then
			imgui.SetNextWindowSize(imgui.ImVec2(650, 360), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"������", imgui_binder, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.SetScrollY(0)
			imgui.BeginChild("ChildWindow",imgui.ImVec2(175,270),false,imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 160) / 2)
			for key, value in pairs(configuration.BindsName) do
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 160) / 2)
					if imgui.Button(u8(configuration.BindsName[key]),imgui.ImVec2(160,30)) then
						choosedslot = key
						binderbuff.v = tostring(configuration.BindsAction[key]):gsub("~", "\n")
						binderbuff.v = u8(binderbuff.v)
						bindername.v = u8(configuration.BindsName[key])
						bindertype.v = u8(configuration.BindsType[key])
						bindercmd.v = u8(configuration.BindsCmd[key])
						binderkeystatus = configuration.BindsKeys[key]
						binderdelay.v = tostring(configuration.BindsDelay[key])
					end
			end
			imgui.EndChild()
			if choosedslot ~= nil and choosedslot <= configuration.binder_settings.totalslots then
				imgui.SameLine()
				imgui.BeginChild("ChildWindow2",imgui.ImVec2(435,200),false)
				imgui.InputTextMultiline(u8"",binderbuff, imgui.ImVec2(435,200))
				imgui.EndChild()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� �����:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� �����:').y - 135) / 2)
				imgui.Text(u8'�������� �����:'); imgui.SameLine()
				imgui.PushItemWidth(150)
				if choosedslot ~= 50 then
					imgui.InputText("##bindername", bindername,imgui.InputTextFlags.ReadOnly)
				else
					imgui.InputText("##bindername", bindername)
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(162)
				imgui.Combo(" ",bindertype, u8"������������ �������\0������������ �������\0\0", 2)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� �����:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� ����� �������� (ms):').y - 70) / 2)
				imgui.Text(u8'�������� ����� �������� (ms):'); imgui.SameLine()
				imgui.Hint(u8'���������� �������� � �������������\n1 ������� = 1.000 �����������')
				imgui.PushItemWidth(58)
				imgui.InputText("##binderdelay", binderdelay, imgui.InputTextFlags.CharsDecimal)
				imgui.PopItemWidth()
				imgui.SameLine()
				if bindertype.v == 0 then
					imgui.Text("/")
					imgui.SameLine()
					imgui.PushItemWidth(147)
					imgui.InputText("##bindercmd",bindercmd,imgui.InputTextFlags.CharsNoBlank)
					imgui.PopItemWidth()
				end
				if bindertype.v == 1 then
					if binderkeystatus == nil or binderkeystatus == "" then
						binderkeystatus = u8"������� ����� ��������"
					end
					if imgui.Button(binderkeystatus) then
						if binderkeystatus == u8"������� ����� ��������" then
							table.remove(emptykey1)
							table.remove(emptykey2)
							binderkeystatus = u8"������� ����� �������"
							setbinderkey = true
							getbindkeys()
						elseif binderkeystatus == u8"������� ����� �������" then
							setbinderkey = false
							binderkeystatus = u8"������� ����� ��������"
						elseif string.find(binderkeystatus, u8"���������") then
							setbinderkey = false
							binderkeystatus = string.match(binderkeystatus,u8"��������� (.+)")
						else
							table.remove(emptykey1)
							table.remove(emptykey2)
							binderkeystatus = u8"������� ����� �������"
							keyname = nil
							keyname2 = nil
							setbinderkey = true
							getbindkeys()
						end
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 429) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - 10) / 2)
				local kei
				local doreplace = false
				if binderbuff.v ~= "" and bindername.v ~= "" and binderdelay.v ~= "" and bindertype.v ~= nil then
					if imgui.Button(u8"���������",imgui.ImVec2(100,30)) then
						if not inprocess then
								if bindertype.v == 0 then
									if bindercmd.v ~= "" and bindercmd.v ~= nil then
										for key, value in pairs(configuration.BindsName) do
											if tostring(u8:decode(bindername.v)) == tostring(value) then
												doreplace = true
												kei = key
											end
										end
										if doreplace then
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											configuration.BindsName[kei] = u8:decode(bindername.v)
											configuration.BindsAction[kei] = refresh_text
											configuration.BindsDelay[kei] = u8:decode(binderdelay.v)
											configuration.BindsType[kei]= u8:decode(bindertype.v)
											configuration.BindsCmd[kei] = u8:decode(bindercmd.v)
											configuration.BindsKeys[kei] = ""
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("���� ������� ��������!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										else
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											table.insert(configuration.BindsName, u8:decode(bindername.v))
											table.insert(configuration.BindsAction, refresh_text)
											table.insert(configuration.BindsDelay, u8:decode(binderdelay.v))
											table.insert(configuration.BindsType, u8:decode(bindertype.v))
											table.insert(configuration.BindsCmd, u8:decode(bindercmd.v))
											table.insert(configuration.BindsKeys, "")
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("���� ������� ������!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										end
									else
										ASHelperMessage("�� ����������� ������� ������� �����!")
									end
								elseif bindertype.v == 1 then
									if binderkeystatus ~= nil and (u8:decode(binderkeystatus)) ~= "������� ����� ��������" and not string.find((u8:decode(binderkeystatus)), "��������� ") and (u8:decode(binderkeystatus)) ~= "������� ����� �������" then
										for key, value in pairs(configuration.BindsName) do
											if tostring(u8:decode(bindername.v)) == tostring(value) then
												doreplace = true
												kei = key
											end
										end
										if doreplace then
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											configuration.BindsName[kei] = u8:decode(bindername.v)
											configuration.BindsAction[kei] = refresh_text
											configuration.BindsDelay[kei] = u8:decode(binderdelay.v)
											configuration.BindsType[kei]= u8:decode(bindertype.v)
											configuration.BindsCmd[kei] = ""
											configuration.BindsKeys[kei] = u8(binderkeystatus)
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("���� ������� ��������!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										else
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											table.insert(configuration.BindsName, u8:decode(bindername.v))
											table.insert(configuration.BindsAction, refresh_text)
											table.insert(configuration.BindsDelay, u8:decode(binderdelay.v))
											table.insert(configuration.BindsType, u8:decode(bindertype.v))
											table.insert(configuration.BindsKeys, u8(binderkeystatus))
											table.insert(configuration.BindsCmd, "")
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("���� ������� ������!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										end
									else
										ASHelperMessage("�� ����������� ������� ������� �����!")
									end
								end
							updatechatcommands()
						else
							ASHelperMessage("�� �� ������ ����������������� � �������� �� ����� ����� ���������!")
						end	
					end
				else
					imgui.LockedButton(u8"���������",imgui.ImVec2(100,30))
					imgui.Hint(u8"�� ����� �� ��� ���������. ������������� ��.")
				end
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 247) / 2)
				if imgui.Button(u8"��������",imgui.ImVec2(100,30)) then
					setbinderkey = false
					keyname = nil
					keyname2 = nil
					table.remove(emptykey1)
					table.remove(emptykey2)
					bindercmd.v = ""
					binderbuff.v = ""
					bindername.v = ""
					bindertype.v = 0
					binderdelay.v = ""
					bindercmd.v = ""
					binderkeystatus = nil
					updatechatcommands()
					choosedslot = nil
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(230,180))
				imgui.Text(u8"�������� ���� ��� �������� ����� ��� ���� ��������������.")
			end
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 621) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 10) / 2)
			if imgui.Button(u8"��������",imgui.ImVec2(82,30)) then
				choosedslot = 50
				binderbuff.v = ''
				bindername.v = ''
				bindertype.v = 0
				bindercmd.v = ''
				binderkeystatus = nil
				binderdelay.v = ''
				updatechatcommands()
			end
			imgui.SameLine()
			if choosedslot ~= nil and choosedslot ~= 50 then
				if imgui.Button(u8"�������",imgui.ImVec2(82,30)) then
					if not inprocess then
						for key, value in pairs(configuration.BindsName) do
							value = tostring(value)
							if u8:decode(bindername.v) == tostring(configuration.BindsName[key]) then
								table.remove(configuration.BindsName,key)
								table.remove(configuration.BindsKeys,key)
								table.remove(configuration.BindsAction,key)
								table.remove(configuration.BindsCmd,key)
								table.remove(configuration.BindsDelay,key)
								table.remove(configuration.BindsType,key)
								if inicfg.save(configuration,"AS Helper") then
									setbinderkey = false
									keyname = nil
									keyname2 = nil
									table.remove(emptykey1)
									table.remove(emptykey2)
									bindercmd.v = ""
									binderbuff.v = ""
									bindername.v = ""
									bindertype.v = 0
									binderdelay.v = ""
									bindercmd.v = ""
									binderkeystatus = nil
									choosedslot = nil
									ASHelperMessage("���� ������� �����!")
								end
							end
						end
					updatechatcommands()
					else
						ASHelperMessage("�� �� ������ ������� ���� �� ����� ����� ���������!")
					end
				end
			else
				imgui.LockedButton(u8"�������",imgui.ImVec2(82,30))
				imgui.Hint(u8"�������� ���� ������� ������ �������",0)
			end
			imgui.End()
		end
		
		if imgui_stats.v then
			imgui.SetNextWindowSize(imgui.ImVec2(150, 195), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(-1.05, 0.5))
			imgui.Begin(u8"���� ����������", imgui_stats, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.Text(u8"���� - "..configuration.my_stats.avto)
			imgui.Text(u8"���� - "..configuration.my_stats.moto)
			imgui.Text(u8"����������� - "..configuration.my_stats.riba)
			imgui.Text(u8"�������� - "..configuration.my_stats.lodka)
			imgui.Text(u8"������ - "..configuration.my_stats.guns)
			imgui.Text(u8"����� - "..configuration.my_stats.hunt)
			imgui.Text(u8"�������� - "..configuration.my_stats.klad)
			imgui.End()
		end
	end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then
	return end
	while not isSampAvailable() do
		wait(200)
	end
	local checking = checkbibl()
	while not checking do
		wait(200)
	end
	while not string.find(sampGetCurrentServerName(), "Arizona") do
		wait(200)
	end
	while not sampIsLocalPlayerSpawned() do
		wait(200)
	end
	if not doesFileExist('moonloader/config/AS Helper.ini') then
        if inicfg.save(configuration, 'AS Helper.ini') then
			ASHelperMessage('������ ���� ������������.')
		end
    end
	getmyrank = true
	sampSendChat("/stats")
	ASHelperMessage('AS Helper ������� ��������. �����: JustMini')
	ASHelperMessage("������� /"..cmdhelp.." ����� ������� ���������.")
	imgui.Process = false
	sampRegisterChatCommand(cmdhelp, fastmenuopen)
	sampRegisterChatCommand(cmdbind, binder)
	sampRegisterChatCommand(cmdupdate, updaterank)
	sampRegisterChatCommand(cmdstats, checkmystats)
	sampRegisterChatCommand("uninvite", function(param)
		if configuration.main_settings.dorponcmd then
			uninvitewithcmd(param)
		else
			sampSendChat("/uninvite "..param)
		end
	end)
	sampRegisterChatCommand("invite", function(param)
		if configuration.main_settings.dorponcmd then
			invite(param)
		else
			sampSendChat("/invite "..param)
		end
	end)
	sampRegisterChatCommand("giverank", function(param)
		if configuration.main_settings.dorponcmd then
			giverank(param)
		else
			sampSendChat("/giverank "..param)
		end
	end)
	sampRegisterChatCommand("blacklist", function(param)
		if configuration.main_settings.dorponcmd then
			blacklist(param)
		else
			sampSendChat("/blacklist "..param)
		end
	end)
	sampRegisterChatCommand("unblacklist", function(param)
		if configuration.main_settings.dorponcmd then
			unblacklist(param)
		else
			sampSendChat("/unblacklist "..param)
		end
	end)
	sampRegisterChatCommand("fwarn", function(param)
		if configuration.main_settings.dorponcmd then
			fwarn(param)
		else
			sampSendChat("/fwarn "..param)
		end
	end)
	sampRegisterChatCommand("unfwarn", function(param)
		if configuration.main_settings.dorponcmd then
			unfwarn(param)
		else
			sampSendChat("/unfwarn "..param)
		end
	end)
	sampRegisterChatCommand("fmute", function(param)
		if configuration.main_settings.dorponcmd then
			fmute(param)
		else
			sampSendChat("/fmute "..param)
		end
	end)
	sampRegisterChatCommand("funmute", function(param)
		if configuration.main_settings.dorponcmd then
			funmute(param)
		else
			sampSendChat("/funmute "..param)
		end
	end)
	sampRegisterChatCommand("expel", function(param)
		if configuration.main_settings.dorponcmd then
			expel(param)
		else
			sampSendChat("/expel "..param)
		end
	end)
	sampRegisterChatCommand("devmaxrank", devmaxrank)
	sampRegisterChatCommand("goodverdict", goodverdict)
	updatechatcommands()

	while true do
		if not imgui.Process then
			if getCharPlayerIsTargeting() then
				local result, targettingped = getCharPlayerIsTargeting()
				if configuration.main_settings.createmarker then
					if sampGetPlayerIdByCharHandle(targettingped) then
						if marker ~= nil and oldtargettingped ~= targettingped then
							removeBlip(marker)
							marker = nil
							marker = addBlipForChar(targettingped)
						elseif marker == nil and oldtargettingped ~= targettingped then
							marker = addBlipForChar(targettingped)
						end
					end
				end
				oldtargettingped = targettingped
				local button = configuration.main_settings.usefastmenu
				if wasKeyPressed(vkeys.name_to_id(button,true)) then
					if not sampIsChatInputActive() then
						local result, targettingid = sampGetPlayerIdByCharHandle(targettingped)
						if targettingid ~= -1 then
							if not imgui_fm.v then
								fastmenuID = targettingid
								ASHelperMessage("�� ������������ ���� �������� ������� ��: "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").."["..fastmenuID.."]")
								ASHelperMessage("������� {ff6633}ALT{FFFFFF} ��� ����, ����� ������ ������. {ff6633}ESC{FFFFFF} ��� ����, ����� ������� ����.")
								windowtype.v = 0
								imgui_fm.v = true
							end
						end
					end
				end
			end
		end
		if imgui_settings.v or imgui_fm.v or imgui_binder.v or imgui_stats.v or imgui_sobes.v then
			if not imgui.Process then
				imgui.Process = true
				imgui.ShowCursor = true
			end
			if isKeyDown(0x12) then
				imgui.ShowCursor = false
			else
				imgui.ShowCursor = true
			end
			if wasKeyPressed(0x1B) then
				while isKeyDown(0x1B) do
					wait(0)
				end
				disableallimgui()
				imgui_binder.v = false
				imgui_stats.v = false
				imgui.ShowCursor = false
			end
		else
			if imgui.Process then
				imgui.Process = false
			end
		end
		for key, value in pairs(configuration.BindsName) do
			if tostring(value):find(configuration.BindsName[key]) then
				if configuration.BindsKeys[key] ~= "" then
					if configuration.BindsKeys[key]:match("(.+) %p (.+)") then
						local fkey = configuration.BindsKeys[key]:match("(.+) %p")
						local skey = configuration.BindsKeys[key]:match("%p (.+)")
						if isKeyDown(vkeys.name_to_id(fkey,true)) and wasKeyPressed(vkeys.name_to_id(skey,true)) then
							if not inprocess then
								inprocess = true
								for bp in configuration.BindsAction[key]:gmatch('[^~]+') do
									sampSendChat(tostring(bp))
									wait(configuration.BindsDelay[key])
								end
								inprocess = false
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						end
					elseif configuration.BindsKeys[key]:match("(.+)") then
						local fkey = configuration.BindsKeys[key]:match("(.+)")
						if wasKeyPressed(vkeys.name_to_id(fkey,true)) then
							if not inprocess then
								inprocess = true
								for bp in configuration.BindsAction[key]:gmatch('[^~]+') do
									sampSendChat(tostring(bp))
									wait(configuration.BindsDelay[key])
								end
								inprocess = false
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						end
					end
				end
			end
		end
		wait(0)
	end
end

function fastmenuopen()
	disableallimgui()
	imgui_settings.v = not imgui_settings.v
	userset = false
	licset = false
	keysset = false
	otherset = false
	scriptinfo = false
end

function faslfak()
	imgui_fm.v = not imgui_fm.v
end

function binder()
	choosedslot = nil
	imgui_binder.v = not imgui_binder.v
end

function updaterank()
	getmyrank = true
	sampSendChat("/stats")
end

function checkmystats()
	imgui_stats.v = not imgui_stats.v
end

function hello()
	lua_thread.create(function()
		if inprocess ~= true then
			getmyrank = true
			sampSendChat("/stats")
			local hour = tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60))
			if configuration.main_settings.useservername then
				local result,myid = sampGetPlayerIdByCharHandle(playerPed)
				name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
			else
				name = u8:decode(myname.v)
				if name == '' or name == nil then
					ASHelperMessage('������� ��� ��� � /'..cmdhelp..' ')
					local result,myid = sampGetPlayerIdByCharHandle(playerPed)
					name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
				end
			end
			local rang = configuration.main_settings.myrank
			inprocess = true
			if hour > 4 and hour < 13 then
				sampSendChat("������ ����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
			elseif hour > 12 and hour < 17 then
				sampSendChat("������ ����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
			elseif hour > 16 and hour < 24 then
				sampSendChat("������ �����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
			elseif hour < 5 then
				sampSendChat("������ ����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
			end
			wait(cd)
			sampSendChat('/do �� ����� ����� ������� � �������� '..rang..' '..name..".")
			inprocess = false
		else
			ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
		end
	end)
end

function pricelist()
	lua_thread.create(function()
		if inprocess ~= true then
			inprocess = true
			sampSendChat('/do � ������� ���� ����� ����� ���� �� ��������.')
			wait(cd)
			sampSendChat('/me {gender:������|�������} ����� ���� �� ������� ���� � ������� ��� �������')
			wait(cd)
			sampSendChat('/do � ����� ����� ��������:')
			wait(cd)
			sampSendChat('/do �������� �� �������� ����������� - '..separator(tostring(configuration.main_settings.avtoprice)..'$.'))
			wait(cd)
			sampSendChat('/do �������� �� �������� ���������� - '..separator(tostring(configuration.main_settings.motoprice)..'$.'))
			wait(cd)
			sampSendChat('/do �������� �� ����������� - '..separator(tostring(configuration.main_settings.ribaprice)..'$.'))
			wait(cd)
			sampSendChat('/do �������� �� ������ ��������� - '..separator(tostring(configuration.main_settings.lodkaprice)..'$.'))
			wait(cd)
			sampSendChat('/do �������� �� ������ - '..separator(tostring(configuration.main_settings.gunaprice)..'$.'))
			wait(cd)
			sampSendChat('/do �������� �� ����� - '..separator(tostring(configuration.main_settings.huntprice)..'$.'))
			wait(cd)
			sampSendChat('/do �������� �� �������� - '..separator(tostring(configuration.main_settings.kladprice)..'$.'))
			inprocess = false
		else
			ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
		end
	end)
end

function selllic(param)
	lua_thread.create(function()
		sellto, lictype = param:match('(.+) (.+)')
		local sellto = tonumber(sellto)
		local result, myid = sampGetPlayerIdByCharHandle(playerPed)
		if lictype ~= nil and sellto ~= nil then
			if inprocess ~= true then
				inprocess = true
					if lictype == '������' or lictype == '�����' then
						sampSendChat('�������� �������� �� '..lictype..' �� ������ � ��������� �. ���-��������')
						sampSendChat('/n /gps -> ������ ����� -> ��������� �������� -> [LV] ��������� (9)')
					elseif lictype == '������' then
						if not cansell then
							result, myid = sampGetPlayerIdByCharHandle(playerPed)
							if sampIsPlayerConnected(sellto) or sellto == myid then
								sampSendChat('������, ��� ������� �������� �� ������ �������� ��� ���� ���.�����')
								sampSendChat('/n /showmc '..myid)
								ASHelperMessage('�������� �������� ������ ���.�����.')
								skiporcancel = false
								choosedname = sampGetPlayerNickname(fastmenuID)
								tempid = fastmenuID
							else
								ASHelperMessage('������ ������ ��� �� �������')
							end
						else
							inprocess = true
							sampSendChat('/me {gender:����|�����} �� ����� ����� � {gender:��������|���������} ������ ����� �� ��������� �������� �� '..lictype)
							wait(cd)
							sampSendChat('/do ������ ��������� ����� ����� �� ��������� �������� ��� ��������.')
							wait(cd)
							sampSendChat('/me ���������� �������� �� '..lictype.." {gender:�������|��������} � �������� ��������")
							givelic = true
							cansell = false
							wait(100)
							sampSendChat('/givelicense '..sellto)
						end
					else
						sampSendChat('/me {gender:����|�����} �� ����� ����� � {gender:��������|���������} ������ ����� �� ��������� �������� �� '..lictype)
						wait(cd)
						sampSendChat('/do ������ ��������� ����� ����� �� ��������� �������� ��� ��������.')
						wait(cd)
						sampSendChat('/me ���������� �������� �� '..lictype.." {gender:�������|��������} � �������� ��������")
						givelic = true
						wait(100)
						sampSendChat('/givelicense '..sellto)
					end
				inprocess = false
			else
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			end
		end
	end)
end

function invite(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
				if id == nil then
					ASHelperMessage('/invite [id]')
				else
					local result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						ASHelperMessage('�� �� ������ ���������� � ����������� ������ ����.')
					else
						inprocess = true
						sampSendChat('/do ����� �� �������� � �������.')
						wait(cd)
						sampSendChat('/me ������ ���� � ������ ����, {gender:������|�������} ������ ���� �� ��������')
						wait(cd)
						sampSendChat('/me {gender:�������|��������} ���� �������� ��������')
						wait(cd)
						sampSendChat('����� ����������! ���������� �� ������.')
						wait(cd)
						sampSendChat('�� ���� ����������� �� ������ ������������ �� ��. �������.')
						sampSendChat("/invite "..id)
						inprocess = false
					end
				end
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function uninvite(param)
	local id, withbl = param:match("(%d+) (%d)")
	local id = tonumber(id)
	local withbl = tonumber(withbl)
	lua_thread.create(function()
		inprocess = true
		if withbl == 0 then
			sampSendChat('/me {gender:������|�������} ��� �� �������')
			wait(cd)
			sampSendChat('/me {gender:�������|�������} � ������ "����������"')
			wait(cd)
			sampSendChat('/do ������ ������.')
			wait(cd)
			sampSendChat('/me {gender:����|������} �������� � ������ "����������"')
			wait(cd)
			sampSendChat('/me {gender:�����������|�����������} ���������, ����� {gender:��������|���������} ��� � {gender:�������|��������} ��� ������� � ������')
			wait(cd)
			sampSendChat("/uninvite "..id..' '..u8:decode(uninvitebuf.v))
		elseif withbl == 1 then
			sampSendChat('/me {gender:������|�������} ��� �� �������')
			wait(cd)
			sampSendChat('/me {gender:�������|�������} � ������ "����������"')
			wait(cd)
			sampSendChat('/do ������ ������.')
			wait(cd)
			sampSendChat('/me {gender:����|������} �������� � ������ "����������"')
			wait(cd)
			sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
			wait(cd)
			sampSendChat('/me {gender:�����|�������} ���������� � ������, ����� ���� {gender:����������|�����������} ���������')
			wait(cd)
			sampSendChat('/do ��������� ���� ���������.')
			wait(cd)
			sampSendChat("/uninvite "..id..' '..u8:decode(uninvitebuf.v))
			wait(100)
			sampSendChat("/blacklist "..id..' '..u8:decode(blacklistbuf.v))
		end
		inprocess = false
	end)
end

function uninvitewithcmd(param)
	local uvalid,reason = param:match("(%d+) (.+)")
	local uvalid = tonumber(uvalid)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
				inprocess = true
				if uvalid == nil or uvalid == '' or reason == nil or reason == '' then
					ASHelperMessage('/uninvite [id] [�������]')
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if uvalid == myid then
						ASHelperMessage('�� �� ������ ��������� �� ����������� ������ ����.')
					else
						sampSendChat('/me {gender:������|�������} ��� �� �������')
						wait(cd)
						sampSendChat('/me {gender:�������|�������} � ������ "����������"')
						wait(cd)
						sampSendChat('/do ������ ������.')
						wait(cd)
						sampSendChat('/me {gender:����|������} �������� � ������ "����������"')
						wait(cd)
						sampSendChat('/me {gender:�����������|�����������} ���������, ����� {gender:��������|���������} ��� � {gender:�������|��������} ��� ������� � ������')
						sampSendChat("/uninvite "..uvalid..' '..reason)
					end
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function giverank(param)
	local id,rank = param:match("(%d+) (%d)")
	local id = tonumber(id)
	local rank = tonumber(rank)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
				inprocess = true
				if id == nil or id == '' or rank == nil or rank == '' then
					ASHelperMessage('/giverank [id] [����]')
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						ASHelperMessage('�� �� ������ ������ ���� ������ ����.')
					else
						sampSendChat('/me {gender:�������|��������} ���')
						wait(cd)
						sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
						wait(cd)
						sampSendChat('/me {gender:������|�������} � ������� ������� ����������')
						wait(cd)
						sampSendChat('/me {gender:�������|��������} ���������� � ��������� ����������, ����� ���� {gender:�����������|�����������} ���������')
						wait(cd)
						sampSendChat('/do ���������� � ���������� ���� ��������.')
						wait(cd)
						sampSendChat('���������� � ����������. ����� ������� �� ������ ����� � ����������.')
						sampSendChat("/giverank "..id.." "..rank)
					end
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function blacklist(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
				inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/blacklist [id] [�������]')
				else
					sampSendChat("/me {gender:������|�������} ��� �� �������")
					wait(cd)
					sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
					wait(cd)
					sampSendChat("/me {gender:���|�����} ��� ����������")
					wait(cd)
					sampSendChat('/me {gender:����|������} ���������� � ������ "׸���� ������"')
					wait(cd)
					sampSendChat("/me {gender:�����������|�����������} ���������")
					wait(cd)
					sampSendChat("/do ��������� ���� ���������.")
					sampSendChat("/blacklist "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function unblacklist(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
			inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/unblacklist [id]')
				else
					sampSendChat("/me {gender:������|�������} ��� �� �������")
					wait(cd)
					sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
					wait(cd)
					sampSendChat("/me {gender:���|�����} ��� ���������� � �����")
					wait(cd)
					sampSendChat('/me {gender:�����|������} ���������� �� ������� "׸���� ������"')
					wait(cd)
					sampSendChat("/me {gender:�����������|�����������} ���������")
					wait(cd)
					sampSendChat("/do ��������� ���� ���������.")
					sampSendChat("/unblacklist "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function fwarn(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/fwarn [id] [�������]')
				else
					sampSendChat('/me {gender:������|�������} ��� �� �������')
					wait(cd)
					sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
					wait(cd)
					sampSendChat('/me {gender:�����|�����} � ������ "��������"')
					wait(cd)
					sampSendChat('/me ����� � ������� ������� ����������, {gender:�������|��������} � ��� ������ ���� �������')
					wait(cd)
					sampSendChat('/do ������� ��� �������� � ������ ���� ����������.')
					wait(cd)
					sampSendChat("/fwarn "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function unfwarn(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
				inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/unfwarn [id]')
				else
					sampSendChat("/me {gender:������|�������} ��� �� �������")
					wait(cd)
					sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
					wait(cd)
					sampSendChat('/me {gender:�����|�����} � ������ "��������"')
					wait(cd)
					sampSendChat("/me ����� � ������� ������� ����������, {gender:�����|������} �� ��� ������� ���� ���� �������")
					wait(cd)
					sampSendChat('/do ������� ��� ����� �� ������� ���� ����������.')
					sampSendChat("/unfwarn "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function fmute(param)
	local id,mutetime,reason = param:match("(%d+) (%d+) (.+)")
	local id = tonumber(id)
	local mutetime = tonumber(mutetime)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/fmute [id] [�����] [�������]')
				else
					sampSendChat('/me {gender:������|�������} ��� �� �������')
					wait(cd)
					sampSendChat('/me {gender:�������|��������} ���')
					wait(cd)
					sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������ ���������"')
					wait(cd)
					sampSendChat('/me {gender:������|�������} ������� ����������')
					wait(cd)
					sampSendChat('/me {gender:������|�������} ����� "��������� ����� ����������"')
					wait(cd)
					sampSendChat('/me {gender:�����|������} �� ������ "��������� ���������"')
					sampSendChat("/fmute "..id.." "..mutetime.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function funmute(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
				inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/funmute [id]')
				else
					sampSendChat('/me {gender:������|�������} ��� �� �������')
					wait(cd)
					sampSendChat('/me {gender:�������|��������} ���')
					wait(cd)
					sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������ ���������"')
					wait(cd)
					sampSendChat('/me {gender:������|�������} ������� ����������')
					wait(cd)
					sampSendChat('/me {gender:������|�������} ����� "�������� ����� ����������"')
					wait(cd)
					sampSendChat('/me {gender:�����|������} �� ������ "��������� ���������"')
					sampSendChat("/funmute "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 9-�� �����.")
		end
	end)
end

function expel(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 5 then
			if inprocess then
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			else
				inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/expel [id] [�������]')
				else
					sampSendChat('/do ����� ������� �� �����.')
					wait(cd)
					sampSendChat('/me ���� ����� � �����, {gender:������|�������} ������ �� ���')
					wait(cd)
					sampSendChat('/do ������ ������� ���������� �� �����.')
					sampSendChat("/expel "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("������ ������� �������� � 5-�� �����.")
		end
	end)
end

function sobes1()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
		else
			inprocess = true
			if configuration.main_settings.useservername then
				local result,myid = sampGetPlayerIdByCharHandle(playerPed)
				name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
			else
				name = u8:decode(configuration.main_settings.myname)
				if name == '' or name == nil then
					ASHelperMessage('������� ��� ��� � /'..cmdhelp..' ')
					local result,myid = sampGetPlayerIdByCharHandle(playerPed)
					name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
				end
			end
			local rang = configuration.main_settings.myrank
			sampSendChat("������������, �� �� �������������?")
			wait(cd)
			sampSendChat('/do �� ����� ����� ������� � �������� '..rang..' '..name)
			inprocess = false
		end
	end)
end

function sobes2()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
		else
			inprocess = true
			sampSendChat("������, ��� ����� �������� ��� ���� ���������, � ������: ������� � ���.�����")
			sampSendChat("/n ����������� �� ��!")
			wait(50)
			sobesetap.v = 1
			inprocess = false
		end
	end)
end

function sobesaccept1()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
		else
			inprocess = true
			wait(50)
			sobesetap.v = 2
			sampSendChat("/me ���� ��������� �� ��� �������� �������� {gender:�����|������} �� ���������")
			wait(cd)
			sampSendChat("/todo ������...* ������� ��������� �������")
			wait(cd)
			sampSendChat("������ � ����� ��� ��������� ��������, �� ������ �� ��� ��������?")
			inprocess = false
		end
	end)
end

function sobesaccept2()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
		else
			inprocess = true
			if configuration.main_settings.myrankint >= 9 then
				sampSendChat("�������, � ����� �� ��� ���������!")
				wait(cd)
				inprocess = false
				invite(tostring(fastmenuID))
			else
				sampSendChat("�������, � ����� �� ��� ���������!")
				wait(cd)
				sampSendChat("/r "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").." ������� ������ �������������! �� ��� ������� ����� ������ ����� �� ��� �������.")
				wait(cd)
				sampSendChat("/rb "..fastmenuID.." id")
			end
			inprocess = false
		end
	end)
end

function sobesdecline(param)
	local reason = param:match("(.+)")
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
		else
			inprocess = true
			if reason ~= "����. �������������1" and reason ~= "����. �������������3" and reason ~= "����. �������������5" then
				sampSendChat("/me ���� ��������� �� ��� �������� �������� {gender:�����|������} �� ���������")
				wait(cd)
				sampSendChat("/todo ����� �������...* ������� ��������� �������")
				wait(cd)
			end
			if reason == ("����������������") then
				sampSendChat("� ��������� � �� ���� ���������� ������������� ������ ���, �� ������� ��������������.")
			elseif reason == ("�� ��������� ��������") then
				sampSendChat("� ��������� � �� ���� ���������� ������������� ������ ���, �� �� ��������� ��������.")
			elseif reason == ("�� ���������������") then
				sampSendChat("� ��������� � �� ���� ���������� ������������� ������ ���, �� ������������ ���������������.")
			elseif reason == ("������ 3 ��� � �����") then
				sampSendChat("� ��������� � �� ���� ���������� ������������� ������ ���, �� �� ���������� � ����� 3 ����.")
			elseif reason == ("����� � �����������") then
				sampSendChat("� ��������� � �� ���� ���������� ������������� ������ ���, �� ��� ��������� � ������ �����������.")
			elseif reason == ("��� � ���������") then
				sampSendChat("� ��������� � �� ���� ���������� ������������� ������ ���, �� �������� � ����. ��������.")
			elseif reason == ("� �� ���������") then
				sampSendChat("� ��������� � �� ���� ���������� ������������� ������ ���, �� ���������� � �� ��.")
			elseif reason == ("����. �������������1") then
				sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
				sampSendChat("/b ������ �� �������")
			elseif reason == ("����. �������������2") then
				sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
				sampSendChat("/b ������� ��")
			elseif reason == ("����. �������������3") then
				sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
				sampSendChat("/b �� ���� ��")
			elseif reason == ("����. �������������4") then
				sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
				sampSendChat("/b ������ ����������")
			elseif reason == ("����. �������������5") then
				sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
			end
			inprocess = false
		end
	end)
end

function updatechatcommands()
	for key, value in pairs(configuration.BindsName) do
		if tostring(value):find(configuration.BindsName[key]) then
			if configuration.BindsCmd[key] ~= "" then
				sampUnregisterChatCommand(configuration.BindsCmd[key])
				sampRegisterChatCommand(configuration.BindsCmd[key], function()
					lua_thread.create(function()
						if not inprocess then
							for bp in configuration.BindsAction[key]:gmatch('[^~]+') do
								inprocess = true
								sampSendChat(tostring(bp))
								wait(configuration.BindsDelay[key])
								inprocess = false
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end)
				end)
			end
		end
	end
end

if sampevcheck then
	--��������� ������� Bank Helper �� Cosmo. ������ ���� ��������� ���������� ����.
	function sampev.onCreatePickup(id, model, pickupType, position)
		if model == 19132 and getCharActiveInterior(playerPed) == 14 then
			return {id, 1272, pickupType, position}
		end
	end

	function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
		if dialogId == 235 and getmyrank then
			if text:find('�����������') then
				for DialogLine in text:gmatch('[^\r\n]+') do
					local nameRankStats, getStatsRank = DialogLine:match('���������: {B83434}(.+)%p(%d+)%p')
					if tonumber(getStatsRank) then
						rangint = tonumber(getStatsRank)
						rang = nameRankStats
						configuration.main_settings.myrank = rang
						configuration.main_settings.myrankint = rangint
						if nameRankStats:find('����������') or devmaxrankp then
							getStatsRank = 10
							configuration.main_settings.myrank = "����������"
							configuration.main_settings.myrankint = 10
						end
						if inicfg.save(configuration,"AS Helper") then
						end
					end
				end
			else
				ASHelperMessage('�� �� ��������� � ���������, ������ ��������!')
				NoErrors = true
				thisScript():unload()
			end
			getmyrank = false
			return false
		end

		if dialogId == 6 and givelic then
			if lictype == "����" then
				sampSendDialogResponse(dialogId, 1, 0, nil)
			end
			if lictype == "����" then
				sampSendDialogResponse(dialogId, 1, 1, nil)
			end
			if lictype == "�����������" then
				sampSendDialogResponse(dialogId, 1, 3, nil)
			end
			if lictype == "��������" then
				sampSendDialogResponse(dialogId, 1, 4, nil)
			end
			if lictype == "������" then
				sampSendDialogResponse(dialogId, 1, 5, nil)
			end
			if lictype == "�����" then
				sampSendDialogResponse(dialogId, 1, 6, nil)
			end
			if lictype == "��������" then
				sampSendDialogResponse(dialogId, 1, 7, nil)
			end
			givelic = false
			return false
		end

		if dialogId == 1234 then
			if text:find('���� ��������') then
				if not mcvalue then
					if text:find("���: "..sampGetPlayerNickname(fastmenuID)) then
						for DialogLine in text:gmatch('[^\r\n]+') do
							if text:find("��������� ��������") then
							local statusint = DialogLine:match('{CEAD2A}����������������: (%d+)')
								if tonumber(statusint) then
									statusint = tonumber(statusint)
									if statusint <= 5 then
										mcvalue = true
										mcverdict = (u8"� �������")
									else
										mcvalue = true
										mcverdict = (u8"����������������")
									end
								end
							else
								mcvalue = true
								mcverdict = (u8"�� ��������� ��������")
							end
						end
					end
				elseif not skiporcancel then
					if text:find("���: "..choosedname) then
						if text:find("��������� ��������") then
							lua_thread.create(function()
								while inprocess do
									wait(0)
								end
								inprocess = true
								sampSendChat("/me ���� ���.����� � ���� ����� � ���������")
								wait(cd)
								sampSendChat("/do ���.����� � �����.")
								wait(cd)
								sampSendChat("/todo �� � �������* ������� ���.����� �������")
								wait(cd)
								skiporcancel = true
								cansell = true
								inprocess = false
								selllic(tempid..' ������')
							end)
						else
							lua_thread.create(function()
								inprocess = true
								ASHelperMessage('������� �� ��������� ��������, ��������� �������� ���.�����!')
								sampSendChat("/me ���� ���.����� � ���� ����� � ���������")
								wait(cd)
								sampSendChat("/do ���.����� �� � �����.")
								wait(cd)
								sampSendChat("/todo � ���������, � ���.����� ��������, ��� � ��� ���� ����������.* ������� ���.����� �������")
								wait(cd)
								sampSendChat("�������� � � ��������� �����!")
								skiporcancel = true
								cansell = false
								inprocess = false
							end)
						end
						return false
					end
				end
			elseif text:find('�����') then
				if not passvalue then
					for DialogLine in text:gmatch('[^\r\n]+') do
						if text:find("���: {FFD700}"..sampGetPlayerNickname(fastmenuID)) then
							if not text:find('{FFFFFF}�����������:') then
								for DialogLine in text:gmatch('[^\r\n]+') do
									local passstatusint = DialogLine:match('{FFFFFF}��� � �����: {FFD700}(%d+)')
									if tonumber(passstatusint) then
										if tonumber(passstatusint) >= 3 then
											for DialogLine in text:gmatch('[^\r\n]+') do
												local zakonstatusint = DialogLine:match('{FFFFFF}�����������������: {FFD700}(%d+)')
												if tonumber(zakonstatusint) then
													if tonumber(zakonstatusint) >= 35 then
														if not text:find('������� � ��������������� ��������') then
															if not text:find('������� � ��{FF6200} �����������') then
																passvalue = true
																passverdict = (u8"� �������")
															else
																passvalue = true
																passverdict = (u8"� �� ���������")
															end
														else
															passvalue = true
															passverdict = (u8"��� � ���������")
														end
													else
														passvalue = true
														passverdict = (u8"�� ���������������")
													end
												end
											end
										else
											passvalue = true
											passverdict = (u8"������ 3 ��� � �����")
										end
									end
								end
							else
								passvalue = true
								passverdict = (u8"����� � �����������")
							end
						end
					end
				end
			end
		end
	end
	
	function sampev.onServerMessage(color, message)
		if configuration.main_settings.replacechat then
			if message:find('�����������: /jobprogress %[ ID ������ %]') then
				ASHelperMessage("�� ����������� ���� ������� ������������.")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ������������� � ����������� ������') then
				ASHelperMessage("�� ��������� ������� ����, �������� ������!")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ������������� � ������� ������') then
				ASHelperMessage("�� ������ ������� ����, ������� ������!")
				return false
			end
			if message:find('%[����������%] {FFFFFF}�� �������� ����!') then
				ASHelperMessage('�� �������� ����.')
				return false
			end
		end
		if message:find('������� ��') then
			getmyrank = true
			sampSendChat("/stats")
		end
		if message:find("%[����������%] {FFFFFF}�� ������� ������� ��������") then
			typeddd, toddd = message:match("%[����������%] {FFFFFF}�� ������� ������� �������� �� (.+) ������ (.+).")
			if typeddd == "����" then
				configuration.my_stats.avto = configuration.my_stats.avto + 1
			elseif typeddd == "����" then
				configuration.my_stats.moto = configuration.my_stats.moto + 1
			elseif typeddd == "�������" then
				configuration.my_stats.riba = configuration.my_stats.riba + 1
			elseif typeddd == "��������" then
				configuration.my_stats.lodka = configuration.my_stats.lodka + 1
			elseif typeddd == "������" then
				configuration.my_stats.guns = configuration.my_stats.guns + 1
			elseif typeddd == "�����" then
				configuration.my_stats.hunt = configuration.my_stats.hunt + 1
			elseif typeddd == "��������" then
				configuration.my_stats.klad = configuration.my_stats.klad + 1
			else
				if configuration.main_settings.replacechat then
					ASHelperMessage("�� ������� ������� �������� �� "..typeddd.." ������ "..toddd:gsub("_"," ")..".")
					return false
				end
			end
			if inicfg.save(configuration,"AS Helper") then
				if configuration.main_settings.replacechat then
					ASHelperMessage("�� ������� ������� �������� �� "..typeddd.." ������ "..toddd:gsub("_"," ")..". ��� ���� ��������� � ���� ����������.")
					return false
				else
				end
			end
		end
		if message:find("������������ ������ ����� ����� ����������� (.+), �������� ���������: (.+)") then
			local result,myid = sampGetPlayerIdByCharHandle(playerPed)
			local invited,inviting = message:match("������������ ������ ����� ����� ����������� (.+), �������� ���������: (.+)%[")
			if inviting == sampGetPlayerNickname(myid) then
				if invited == sampGetPlayerNickname(waitingaccept) then
					sampSendChat("/giverank "..waitingaccept.." 2")
					waitingaccept = false
					ASHelperMessage(string.gsub(sampGetPlayerNickname(waitingaccept), "_", " ").." ������ ���� ����������� �������� � ��������� � ��� ������� �� ��������� ������������.")
					return false
				end
			end
		end
	end
	
	function sampev.onSendChat(message)
		if message:find('{gender:%A+|%A+}') then
			local male, female = message:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = message:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = message:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
		--������ ������� Raymond: https://www.blast.hk/threads/43610/
		if configuration.main_settings.useaccent and configuration.main_settings.myaccent ~= '' and configuration.main_settings.myaccent ~= ' ' then
			if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == "q" then
				return{message}
			end
			if string.find(u8:decode(configuration.main_settings.myaccent), "������") or string.find(u8:decode(configuration.main_settings.myaccent), "������") then
				return{'['..u8:decode(configuration.main_settings.myaccent)..']: '..message}
			else
				return{'['..u8:decode(configuration.main_settings.myaccent)..' ������]: '..message}
			end
		end
	end
	
	function sampev.onSendCommand(cmd)
		if cmd:find('{gender:%A+|%A+}') then
			local male, female = cmd:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
	end
end

function devmaxrank()
	if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == "Carolos_McCandy" then
		devmaxrankp = not devmaxrankp
		sampAddChatMessage("{ff6633}[����� ������������] {FFFFFF}����������� ������������ ����: " ..(devmaxrankp and "{00FF00}��������" or "{FF0000}���������"), 0xff6633)
		getmyrank = true
		sampSendChat("/stats")
	else
		sampAddChatMessage("{ff6347}[������] {FFFFFF}����������� �������! ������� /help ��� ��������� ��������� �������.",0xff6347)
	end
end

function goodverdict()
	if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == "Carolos_McCandy" then
		sampAddChatMessage("{ff6633}[����� ������������] {FFFFFF}�� ����������� ���������� ������� �������� � ���.����� � �������������.", 0xff6633)
		mcvalue = true
		passvalue = true
		mcverdict = (u8"� �������")
		passverdict = (u8"� �������")
	else
		sampAddChatMessage("{ff6347}[������] {FFFFFF}����������� �������! ������� /help ��� ��������� ��������� �������.",0xff6347)
	end
end

function ASHelperMessage(value)
	sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}"..value,0xff6633)
end

--���������� �������� ���� �� ����� �� Royan_Millans: https://www.blast.hk/threads/39380/
function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function separator(text)
	if text:find("$") then
	    for S in string.gmatch(text, "%$%d+") do
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	    for S in string.gmatch(text, "%d+%$") do
	    	S = string.sub(S, 0, #S-1)
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	end
	return text
end

--�������: https://www.blast.hk/threads/71224/
function getbindkeys()
	lua_thread.create(function()
		while true do
			wait(0)
			if getbindkey then
				for i, key in ipairs(log) do
					local keyname = vkeys.id_to_name(key)
					bind = keyname
					configuration.main_settings.usefastmenu = keyname
					if inicfg.save(configuration,"AS Helper") then
					end
					getbindkey = false
				end
			elseif setbinderkey then
				if emptykey1[1] ~= nil and keyname == nil then
					keyname = vkeys.id_to_name(emptykey1[1])
					binderkeystatus = u8"��������� "..keyname
				elseif emptykey2[1] ~= nil and keyname2 == nil then
					keyname2 = vkeys.id_to_name(emptykey2[1])
					if keyname2 == "Shift" or keyname2 == "Alt" or keyname2 == "Ctrl" or keyname2 == "Space" then
						binderkeystatus = keyname2.." + "..keyname
						setbinderkey = false
					else
						binderkeystatus = keyname.." + "..keyname2
						setbinderkey = false
					end
				end
			else
				break
			end
		end 
	end)
end

function onWindowMessage(msg, wparam, lparam)
    if wparam == 0x1B then
    	if imgui_settings.v or imgui_fm.v or imgui_stats.v or imgui_binder.v or imgui_sobes.v then
        	consumeWindowMessage(true, false)
        end
	end
	if getbindkey then
		if msg == 0x100 or msg == 0x104 then
			if not log[1] then
				table.insert(log, 1, wparam)
			end
		end
	end
	if setbinderkey then
		if msg == 0x100 or msg == 0x104 then
			if not emptykey1[1] then
				table.insert(emptykey1, 1, wparam)
			elseif not emptykey2[1] and wparam ~= emptykey1[1] then
				table.insert(emptykey2, 1, wparam)
			end
		end
	end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        if not sampIsDialogActive() then
            showCursor(false, false)
        end
        if inicfg.save(configuration, 'AS Helper.ini') then 
        end
		if NoErrors then
			return false
		end
    	sampShowDialog(1313, "{ff6633}[AS Helper]{ffffff} ������ ��� �������� ��� �� ����.", [[
{ffffff}                                                                             ��� ������ � ����� �������?{f51111}

���� �� �������������� ������������� ������, �� ������ ������� ��� ���������� ����.
� ���� ������, ��� ������ ����������� ������������ ������ ������� ���������� ������ CTRL + R.
���� �� ��� �� �������, �� ������� ��������� ������.{ff6633}

1. �������� � ��� ����������� ������ LUA ����� � �������, ����������� ������� ��.

2. �������� �� �� ������������ ��������� ����������, � ������:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26

3. ���� ������ ������ �� ���� �����, ����������� ������� ��������� ��������:
- � ����� moonloader > config > ������� ���� AS Helper.ini

4. ���� ������ �� ������������������ �� ��������� ������, �� ������� ���������� ������ �� ������ ������.]], "��", nil, 0)
	end
end

function disableallimgui()
	imgui_settings.v = false
	imgui_fm.v = false
	imgui_sobes.v = false
	mcvalue = true
	passvalue = true
end

if imguicheck then
end

function checkbibl()
	if not sampevcheck then
		ASHelperMessage("����������� ���������� samp events. ������� � ����������.")
		createDirectory('moonloader/lib/samp')
		createDirectory('moonloader/lib/samp/events')
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events.lua', 'moonloader/lib/samp/events.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/raknet.lua', 'moonloader/lib/samp/raknet.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/raknet.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/synchronization.lua', 'moonloader/lib/samp/synchronization.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/synchronization.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/bitstream_io.lua', 'moonloader/lib/samp/events/bitstream_io.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/bitstream_io.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/core.lua', 'moonloader/lib/samp/events/core.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/core.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/extra_types.lua', 'moonloader/lib/samp/events/extra_types.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/extra_types.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/handlers.lua', 'moonloader/lib/samp/events/handlers.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/handlers.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/utils.lua', 'moonloader/lib/samp/events/utils.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/utils.lua') then
					ASHelperMessage("���������� samp events ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(-1)
	end
	if not encodingcheck then
		ASHelperMessage("����������� ���������� encoding. ������� � ����������.")
		if doesFileExist('moonloader/lib/encoding.lua') then
			os.remove('moonloader/lib/encoding.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', 'moonloader/lib/encoding.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/encoding.lua') then
					ASHelperMessage("���������� encoding ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(-1)
	end
	if not imguicheck then
		ASHelperMessage("����������� ���������� imgui. ������� � ����������.")
		if doesFileExist('moonloader/lib/imgui.lua') then
			os.remove('moonloader/lib/imgui.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/imgui.lua', 'moonloader/lib/imgui.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/imgui.lua') then
					ASHelperMessage("���������� imgui ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(-1)
	end
	if not facheck then
		ASHelperMessage("����������� ���������� fAwesome5. ������� � ����������.")
		if doesFileExist('moonloader/lib/fAwesome5.lua') then
			os.remove('moonloader/lib/fAwesome5.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/fAwesome5.lua', 'moonloader/lib/fAwesome5.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/fAwesome5.lua') then
					ASHelperMessage("���������� fAwesome5 ���� ������� �����������.")
					fa = require"fAwesome5"
					fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
	end
	if not doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
		ASHelperMessage("����������� ���� ������. ������� ��� ����������.")
		createDirectory('moonloader/resource/fonts')
		downloadUrlToFile('https://github.com/Just-Mini/biblioteki/raw/main/fa-solid-900.ttf', 'moonloader/resource/fonts/fa-solid-900.ttf', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
					ASHelperMessage("���� ������ ��� ������� ����������.")
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
	end
	if doesFileExist('moonloader/config/updateashelper.ini') then
		os.remove('moonloader/config/updateashelper.ini')
	end
	createDirectory('moonloader/config')
	downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/update.ini', 'moonloader/config/updateashelper.ini', function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist('moonloader/config/updateashelper.ini') then
				updates = io.open('moonloader/config/updateashelper.ini','r')
				local tempdata = {}
				for line in updates:lines() do
					table.insert(tempdata, line)
				end
				io.close(updates)
				if tonumber(tempdata[1]) > scriptvernumb then
					ASHelperMessage("������� ����������. ������� ���������� ���.")
					doupdate = true
				else
					ASHelperMessage("���������� �� �������.")
					doupdate = false
				end
				os.remove('moonloader/config/updateashelper.ini')
			else
				ASHelperMessage("��������� ������ �� ����� �������� ����������.")
				thisScript():unload()
			end
		end
	end)
	while doupdate == nil do
		wait(300)
	end
	if doupdate then
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/AS%20Helper.lua', thisScript().path,function(id3, status1)
			if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
				NoErrors = true
				ASHelperMessage("���������� ������� �����������.")
			end
		end)
		wait(-1)
	end
	return true
end