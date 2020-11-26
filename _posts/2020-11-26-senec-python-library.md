---
title: Accessing SENEC photovoltaic appliances  
subtitle: A small Python library  
layout: post
author: nico
category: blog
published: true
---

Lately, I've been working on a web app to monitor the energy consumption and production of my house and photovoltaic system. Unfortunately, the vendor of my inverter and battery system does not provide an open API to gather data from the system. That made me have a closer look at the web interface of my SENEC.Home V3 Hybrid Duo appliance, with success :)

You can request specific data from the appliance at _http://IP_OF_YOUR_APPLIANCE/lala.cgi_ using a POST request determining which information should be responded with.

A basic python dict for the request body that gathers the most interesting information looks like this:

    BASIC_REQUEST = {
        'STATISTIC': {
            'CURRENT_STATE': '',                # Current state of the system (int, see SYSTEM_STATE_NAME)
            'LIVE_BAT_CHARGE_MASTER': '',       # Battery charge amount since installation (kWh)
            'LIVE_BAT_DISCHARGE_MASTER': '',    # Battery discharge amount since installation (kWh)
            'LIVE_GRID_EXPORT': '',             # Grid export amount since installation (kWh)
            'LIVE_GRID_IMPORT': '',             # Grid import amount since installation (kWh)
            'LIVE_HOUSE_CONS': '',              # House consumption since installation (kWh)
            'LIVE_PV_GEN': '',                  # PV generated power since installation (kWh)
            'MEASURE_TIME': ''                  # Unix timestamp for above values (ms)
        },
        'ENERGY': {
            'GUI_BAT_DATA_CURRENT': '',         # Battery charge current: negative if discharging, positiv if charging (A)
            'GUI_BAT_DATA_FUEL_CHARGE': '',     # Remaining battery (percent)
            'GUI_BAT_DATA_POWER': '',           # Battery charge power: negative if discharging, positiv if charging (W)
            'GUI_BAT_DATA_VOLTAGE': '',         # Battery voltage (V)
            'GUI_GRID_POW': '',                 # Grid power: negative if exporting, positiv if importing (W)
            'GUI_HOUSE_POW': '',                # House power consumption (W)
            'GUI_INVERTER_POWER': '',           # PV production (W)
            'STAT_HOURS_OF_OPERATION': ''       # Appliance hours of operation
        },
        'BMS': {
            'CHARGED_ENERGY': '',               # List: Charged energy per battery
            'DISCHARGED_ENERGY': '',            # List: Discharged energy per battery
            'CYCLES': ''                        # List: Cycles per battery
        },
        'PV1': {
            'MPP_CUR': '',                      # List: MPP current (A)
            'MPP_POWER': '',                    # List: MPP power (W)
            'MPP_VOL': '',                      # List: MPP voltage (V)
            'POWER_RATIO': '',                  # Grid export limit (percent)
            'P_TOTAL': ''                       # ?
        },
        'FACTORY': {
            'DESIGN_CAPACITY': '',              # Battery design capacity (Wh)
            'MAX_CHARGE_POWER_DC': '',          # Battery max charging power (W)
            'MAX_DISCHARGE_POWER_DC': ''        # Battery max discharging power (W)
        }
    }

If this is interesting for you, feel free to use my python library for your projects: [https://gist.github.com/smashnet/82ad0b9d7f0ba2e5098e6649ba08f88a](https://gist.github.com/smashnet/82ad0b9d7f0ba2e5098e6649ba08f88a)
