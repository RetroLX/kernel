// SPDX-License-Identifier: GPL-2.0
/*
 * Anbernic RG552 display panel driver
 *
 * Copyright (C) 2021, Romain Tisserand <romain.tisserand@gmail.com>
 */

#include <linux/delay.h>
#include <linux/device.h>
#include <linux/gpio/consumer.h>
#include <linux/media-bus-format.h>
#include <linux/module.h>
#include <linux/of_device.h>
#include <linux/regulator/consumer.h>

#include <drm/drm_mipi_dsi.h>
#include <drm/drm_modes.h>
#include <drm/drm_panel.h>

#include <video/mipi_display.h>

struct panel_rg552_panel_info {
	const struct drm_display_mode *display_modes;
	unsigned int num_modes;
	u32 bus_format, bus_flags;
};

struct panel_rg552 {
	struct drm_panel panel;
	struct mipi_dsi_device *dsi;

	struct regulator *supply;
	const struct panel_rg552_panel_info *panel_info;

	struct gpio_desc *reset_gpio;
	enum drm_panel_orientation orientation;
};

static const u8 panel_rg552_init_sequence_01 = { 0x39, 0x00, 0x04, 0xB9, 0xFF, 0x83, 0x99 };
static const u8 panel_rg552_init_sequence_02 = { 0x39, 0x00, 0x2B, 0xE0, 0x01, 0x13, 0x17, 0x34, 0x38, 0x3E, 0x2C, 0x47, 0x07, 0x0C, 0x0F, 0x12, 0x14, 0x11, 0x13, 0x12, 0x18, 0x0B, 0x17, 0x07, 0x13, 0x02, 0x14, 0x18, 0x32, 0x37, 0x3D, 0x29, 0x43, 0x07, 0x0E, 0x0C, 0x0F, 0x11, 0x10, 0x12, 0x12, 0x18, 0x0C, 0x17, 0x07, 0x13 };
static const u8 panel_rg552_init_sequence_03 = { 0x39, 0x00, 0x0D, 0xB1, 0x00, 0x7C, 0x38, 0x35, 0x99, 0x09, 0x22, 0x22, 0x72, 0xF2, 0x68, 0x58 };
static const u8 panel_rg552_init_sequence_04 = { 0x15, 0x00, 0x02, 0xD2, 0x99 };
static const u8 panel_rg552_init_sequence_05 = { 0x39, 0x00, 0x20, 0xD3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x30, 0x00, 0x10, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x07, 0x07, 0x03, 0x00, 0x00, 0x00, 0x05, 0x08 };
static const u8 panel_rg552_init_sequence_06 = { 0x39, 0x00, 0x21, 0xD5, 0x00, 0x00, 0x01, 0x00, 0x03, 0x02, 0x00, 0x00, 0x00, 0x00, 0x19, 0x00, 0x18, 0x00, 0x21, 0x20, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x32, 0x32, 0x31, 0x31, 0x30, 0x30 };
static const u8 panel_rg552_init_sequence_07 = { 0x39, 0x00, 0x21, 0xD6, 0x40, 0x40, 0x02, 0x03, 0x00, 0x01, 0x40, 0x40, 0x40, 0x40, 0x18, 0x40, 0x19, 0x40, 0x20, 0x21, 0x40, 0x18, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x32, 0x32, 0x31, 0x31, 0x30, 0x30 };
static const u8 panel_rg552_init_sequence_08 = { 0x39, 0x00, 0x31, 0xD8, 0x28, 0x2A, 0x00, 0x2A, 0x28, 0x02, 0xC0, 0x2A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x02, 0x00, 0x2A, 0x28, 0x02, 0xC0, 0x2A };
static const u8 panel_rg552_init_sequence_09 = { 0x39, 0x00, 0x0B, 0xB2, 0x00, 0x80, 0x10, 0x7F, 0x05, 0x01, 0x23, 0x4D, 0x21, 0x01 };
static const u8 panel_rg552_init_sequence_10 = { 0x39, 0x00, 0x29, 0xB4, 0x00, 0x3F, 0x00, 0x41, 0x00, 0x3D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0F, 0x01, 0x02, 0x05, 0x40, 0x00, 0x00, 0x3A, 0x00, 0x41, 0x00, 0x3D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0F, 0x01, 0x02, 0x05, 0x00, 0x00, 0x00, 0x3A };
static const u8 panel_rg552_init_sequence_11 = { 0x39, 0x00, 0x05, 0xBA, 0x03, 0x82, 0xA0, 0xE5 };
static const u8 panel_rg552_init_sequence_12 = { 0x05, 0x78, 0x01, 0x11 };
static const u8 panel_rg552_init_sequence_13 = { 0x05, 0x78, 0x01, 0x29 };


static inline struct panel_rg552 *to_panel_rg552(struct drm_panel *panel)
{
	return container_of(panel, struct panel_rg552, panel);
}

static int panel_rg552_prepare(struct drm_panel *panel)
{
	struct panel_rg552 *priv = to_panel_rg552(panel);
	unsigned int i;
	int err;

	err = regulator_enable(priv->supply);
	if (err) {
		dev_err(panel->dev, "Failed to enable power supply: %d\n", err);
		return err;
	}

	/* Reset the chip */
	gpiod_set_value_cansleep(priv->reset_gpio, 1);
	usleep_range(10, 1000);
	gpiod_set_value_cansleep(priv->reset_gpio, 0);
	usleep_range(5000, 20000);

	msleep(150);

	err = mipi_dsi_dcs_exit_sleep_mode(priv->dsi);
	if (err) {
		dev_err(panel->dev, "Unable to exit sleep mode: %d\n", err);
		return err;
	}

	msleep(100);

	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence 01: %d\n", err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_02, ARRAY_SIZE(panel_rg552_init_sequence_02));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence 02: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_03, ARRAY_SIZE(panel_rg552_init_sequence_03));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);
	err = mipi_dsi_dcs_write_buffer(priv->dsi, panel_rg552_init_sequence_01, ARRAY_SIZE(panel_rg552_init_sequence_01));
	if (err < 0) {
		dev_err(panel->dev, "Unable to write init sequence %d: %d\n", i, err);
		goto err_disable_regulator;
	}
	//msleep(10);

	// SLEEP OUT  dsi_generic_write_seq(priv->dsi, 0x05, 0xC8, 0x01, 0x11);
	// DISPLAY ON dsi_generic_write_seq(priv->dsi, 0x05, 0x0A, 0x01, 0x29);

	/* Panel is operational 120 msec after reset */
	msleep(120);

	//err = mipi_dsi_dcs_set_display_on(priv->dsi);
	//if (err) {
	//	dev_err(panel->dev, "Unable to enable display: %d\n", err);
	//	return err;
	//}

	dev_dbg(panel->dev, "Panel init sequence done\n");

	return 0;

err_disable_regulator:
	regulator_disable(priv->supply);
	return err;
}

static int panel_rg552_unprepare(struct drm_panel *panel)
{
	struct panel_rg552 *priv = to_panel_rg552(panel);
	int err;

	// DISPLAY OFF dsi_generic_write_seq(priv->dsi, 0x05, 0x14, 0x01, 0x28);
	// SLEEP IN dsi_generic_write_seq(priv->dsi, 0x05, 0x0A, 0x01, 0x10);

	err = mipi_dsi_dcs_enter_sleep_mode(priv->dsi);
	if (err) {
		dev_err(panel->dev, "Unable to enter sleep mode: %d\n", err);
		return err;
	}

	gpiod_set_value_cansleep(priv->reset_gpio, 1);

	regulator_disable(priv->supply);

	return 0;
}

static int panel_rg552_enable(struct drm_panel *panel)
{
	struct panel_rg552 *priv = to_panel_rg552(panel);
	int err;

	err = mipi_dsi_dcs_set_display_on(priv->dsi);
	if (err) {
		dev_err(panel->dev, "Unable to enable display: %d\n", err);
		return err;
	}

	if (panel->backlight) {
		/* Wait for the picture to be ready before enabling backlight */
		usleep_range(10000, 20000);
	}

	return 0;
}

static int panel_rg552_disable(struct drm_panel *panel)
{
	struct panel_rg552 *priv = to_panel_rg552(panel);
	int err;

	err = mipi_dsi_dcs_set_display_off(priv->dsi);
	if (err) {
		dev_err(panel->dev, "Unable to disable display: %d\n", err);
		return err;
	}

	return 0;
}

static int panel_rg552_get_modes(struct drm_panel *panel,
			     struct drm_connector *connector)
{
	struct panel_rg552 *priv = to_panel_rg552(panel);
	const struct panel_rg552_panel_info *panel_info = priv->panel_info;
	struct drm_display_mode *mode;
	unsigned int i;

	for (i = 0; i < panel_info->num_modes; i++) {
		mode = drm_mode_duplicate(connector->dev,
					  &panel_info->display_modes[i]);
		if (!mode)
			return -ENOMEM;

		drm_mode_set_name(mode);

		mode->type = DRM_MODE_TYPE_DRIVER;
		if (panel_info->num_modes == 1)
			mode->type |= DRM_MODE_TYPE_PREFERRED;

		drm_mode_probed_add(connector, mode);
	}

    drm_connector_set_panel_orientation(connector, priv->orientation);
	connector->display_info.bpc = 8;
	connector->display_info.width_mm = mode->width_mm;
	connector->display_info.height_mm = mode->height_mm;
	drm_display_info_set_bus_formats(&connector->display_info,
					 &panel_info->bus_format, 1);
	connector->display_info.bus_flags = panel_info->bus_flags;


	return panel_info->num_modes;
}

static const struct drm_panel_funcs panel_rg552_funcs = {
	.prepare	= panel_rg552_prepare,
	.unprepare	= panel_rg552_unprepare,
	.enable		= panel_rg552_enable,
	.disable	= panel_rg552_disable,
	.get_modes	= panel_rg552_get_modes,
};

static int panel_rg552_probe(struct mipi_dsi_device *dsi)
{
	struct device *dev = &dsi->dev;
	struct panel_rg552 *priv;
	int err;

	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
	if (!priv) {
		dev_err(dev, "Failed to init probe\n");
		return -ENOMEM;
	}

	priv->reset_gpio = devm_gpiod_get(dev, "reset", GPIOD_OUT_HIGH);
	if (IS_ERR(priv->reset_gpio)) {
		dev_err(dev, "Failed to get reset GPIO\n");
		return PTR_ERR(priv->reset_gpio);
	}

	priv->supply = devm_regulator_get(dev, "vcc");
	if (IS_ERR(priv->supply)) {
		err = PTR_ERR(priv->supply);
		if (err != -EPROBE_DEFER)
			dev_err(dev, "Failed to request supply regulator: %d\n", err);
		return err;
	}

	priv->dsi = dsi;
	mipi_dsi_set_drvdata(dsi, priv);

	priv->panel_info = of_device_get_match_data(dev);
	if (!priv->panel_info)
		return -EINVAL;

	// TODO : this should be in panel description as in st7701 / st7703
	/*
			dsi,flags = <(MIPI_DSI_MODE_VIDEO           |
			      MIPI_DSI_MODE_VIDEO_BURST     |
			      MIPI_DSI_MODE_LPM             |
			      MIPI_DSI_MODE_EOT_PACKET)>;

		dsi,format = <MIPI_DSI_FMT_RGB888>;
		dsi,lanes = <4>;
	*/

	dsi->lanes = 4;
	dsi->format = MIPI_DSI_FMT_RGB888;
	dsi->mode_flags = MIPI_DSI_MODE_VIDEO | MIPI_DSI_MODE_VIDEO_BURST |
			  MIPI_DSI_MODE_LPM | MIPI_DSI_MODE_VIDEO_SYNC_PULSE /*| MIPI_DSI_MODE_EOT_PACKET*/ |
			  MIPI_DSI_CLOCK_NON_CONTINUOUS;

	drm_panel_init(&priv->panel, dev, &panel_rg552_funcs,
		       DRM_MODE_CONNECTOR_DSI);

	err = drm_panel_of_backlight(&priv->panel);
	if (err < 0) {
		if (err != -EPROBE_DEFER)
			dev_err(dev, "Failed to attach backlight\n");
		return err;
	}

	err = of_drm_get_panel_orientation(dev->of_node, &priv->orientation);
	if (err < 0) {
		dev_err(dev, "%pOF: failed to get orientation %d\n", dev->of_node, err);
		return err;
	}

	drm_panel_add(&priv->panel);

	err = mipi_dsi_attach(dsi);
	if (err) {
		dev_err(dev, "Failed to attach panel\n");
		drm_panel_remove(&priv->panel);
		return err;
	}

	return 0;
}

static int panel_rg552_remove(struct mipi_dsi_device *dsi)
{
	struct panel_rg552 *priv = mipi_dsi_get_drvdata(dsi);

	mipi_dsi_detach(dsi);
	drm_panel_remove(&priv->panel);

	drm_panel_disable(&priv->panel);
	drm_panel_unprepare(&priv->panel);

	return 0;
}

static const struct drm_display_mode rg552_modes[] = {
	{ /* 60 Hz */
		.clock = 150000,
		.hdisplay = 1152,
		.hsync_start = 1152 + 64,
		.hsync_end = 1152 + 64 + 4,
		.htotal = 1152 + 64 + 4 + 32,
		.vdisplay = 1920,
		.vsync_start = 1920 + 56,
		.vsync_end = 1920 + 56 + 3,
		.vtotal = 1920 + 56 + 3 + 6,
		.width_mm = 69,
		.height_mm = 116,
		.flags = DRM_MODE_FLAG_NHSYNC | DRM_MODE_FLAG_NVSYNC,
	},
};

static const struct panel_rg552_panel_info rg552_panel_info = {
	.display_modes = rg552_modes,
	.num_modes = ARRAY_SIZE(rg552_modes),
	.bus_format = MEDIA_BUS_FMT_RGB888_1X24,
	.bus_flags = DRM_BUS_FLAG_DE_HIGH | DRM_BUS_FLAG_PIXDATA_SAMPLE_NEGEDGE,
};

static const struct of_device_id panel_rg552_of_match[] = {
	{ .compatible = "anbernic,panel-rg552", .data = &rg552_panel_info },
	{ /* sentinel */ }
};
MODULE_DEVICE_TABLE(of, panel_rg552_of_match);

static struct mipi_dsi_driver panel_rg552_driver = {
	.driver = {
		.name = "panel_rg552",
		.of_match_table = panel_rg552_of_match,
	},
	.probe = panel_rg552_probe,
	.remove = panel_rg552_remove,
};
module_mipi_dsi_driver(panel_rg552_driver);

MODULE_AUTHOR("Romain Tisserand <romain.tisserand@gmail.com>");
MODULE_LICENSE("GPL v2");
