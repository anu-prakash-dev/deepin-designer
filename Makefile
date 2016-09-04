all: main
main: ./lib/animation.vala \
      ./lib/constant.vala \
      ./lib/draw.vala \
      ./lib/config.vala \
      ./lib/keymap.vala \
      ./lib/menu.vala \
      ./lib/utils.vala \
      ./lib/xutils.vala \
      ./widget/image_button.vala \
      ./widget/toolbar.vala \
      ./widget/page_panel.vala \
      ./widget/layout_panel.vala \
      ./widget/window_event_area.vala \
      ./widget/dialog.vala \
      ./widget/page_manager.vala \
      ./project_path.c \
      ./widget/window.vala \
      main.vala
	valac -o main \
	-X -w \
	-X -lm \
	-X -DGETTEXT_PACKAGE="deepin-designer" \
    --pkg=gtk+-3.0 \
    --pkg=gee-0.8 \
    --pkg=json-glib-1.0 \
    --pkg=gio-2.0 \
    --pkg=posix \
    --pkg=gdk-x11-3.0 \
    --pkg=xcb \
    --pkg=libsecret-1 \
    --vapidir=./vapi \
    ./lib/animation.vala \
    ./lib/constant.vala \
    ./lib/draw.vala \
    ./lib/config.vala \
    ./lib/keymap.vala \
    ./lib/menu.vala \
    ./lib/utils.vala \
    ./lib/xutils.vala \
	./widget/image_button.vala \
	./widget/toolbar.vala \
	./widget/page_panel.vala \
	./widget/layout_panel.vala \
	./widget/window_event_area.vala \
	./widget/dialog.vala \
	./widget/page_manager.vala \
    ./project_path.c \
    ./widget/window.vala \
    main.vala

clean:
	rm -f main
	rm -f main.vala.c
	rm -f ./lib/*.vala.c
	rm -f ./widget/*.vala.c

