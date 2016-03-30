package com.toolbox.init;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.toolbox.common.AppEnum;
import com.toolbox.common.SystemConfigEnum;
import com.toolbox.schedule.SchedulerJobService;
import com.toolbox.schedule.job.HotRankScheduleJob;
import com.toolbox.schedule.job.StatScheduleJob;
import com.toolbox.web.entity.SystemConfigEmtity;
import com.toolbox.web.service.SystemConfigService;

/**
* @author E-mail:86yc@sina.com
* 
*/
public class SystemInit {
    private final static Log    log = LogFactory.getLog(SystemInit.class);
    @Autowired
    private SchedulerJobService schedulerJobService;
    @Autowired
    private SystemConfigService systemConfigService;

    @PostConstruct
    public void init() {
        configHotInit();
        schedulerHot();
        schedulerStat();
    }

    @PreDestroy
    public void dostory() {
    }

    /**
     * 热门设置初始化
     */
    private void configHotInit() {
        SystemConfigEmtity sc = systemConfigService.findByConfigType(SystemConfigEnum.config_hot.getType());
        if (sc != null) {
            return;
        }
        sc = new SystemConfigEmtity();
        sc.setConfigType(SystemConfigEnum.config_hot.getType());

        JSONObject json = new JSONObject();
        AppEnum[] appEnums = AppEnum.values();
        JSONArray bc = new JSONArray();
        for (AppEnum app2 : appEnums) {
            bc.add(app2.getCollection());
        }
        for (AppEnum app : appEnums) {
            JSONObject cj = new JSONObject();
            cj.put("nu", 50); //热门数量
            cj.put("cycle", 10); //刷新周期
            cj.put("apps", bc);
            json.put(app.getCollection(), cj);
        }
        sc.setConfig(json);
        systemConfigService.save(sc);
        log.info("init >>> config hot init success ~");
    }

    private void schedulerHot() {
        AppEnum[] apps = AppEnum.values();
        for (AppEnum app : apps) {
            try {
                String appType = app.getCollection();
                SystemConfigEmtity config = systemConfigService.findByConfigType(SystemConfigEnum.config_hot.getType());
                JSONObject hcj = config.getConfig();
                JSONObject appCon = hcj.getJSONObject(appType);
                int cycle = appCon.getIntValue("cycle");
                String day = cycle / 24 > 0 ? "*/" + cycle / 24 : "*";
                int hour = cycle % 24;
                //0 0 15 0/3 * ?
                String cron = null;
                if ("*".equals(day)) {
                    cron = "0 0 */" + hour + " *  * ?";
                } else {
                    cron = "0 0 " + hour + " " + day + "  * ?";
                }
                schedulerJobService.addJob(HotRankScheduleJob.class, appType + "HotJob", "HotRankGroup", cron, appType);
            } catch (Exception e) {
            }
        }
        log.info("init >>> schedulerHot init success ~");
    }

    /**
     * 统计的定时任务初始化
     * 每隔3小时执行一次
     */
    private void schedulerStat() {
        String cron = "0 0 */3 * * ?";
        schedulerJobService.addJob(StatScheduleJob.class, "StatScheduleJob", "StatScheduleGroup", cron, null);
        log.info("init >>> schedulerStat init success ~");
    }
}