# Chainlink Automation Monitoring Guide

## Overview

This guide explains how to monitor and observe the Chainlink Automation system integrated with the DeRisk Watchtower platform.

## Monitoring Components

### 1. Grafana Dashboards

#### Main Watchtower Dashboard (`watchtower-dashboard.json`)
- **Automation Health Status**: Real-time health indicator
- **Automation Triggers**: Rate of automation triggers over time
- **Automation Delay**: Current delay in automation execution
- **Automation Success Rate**: Percentage of successful automation executions
- **Critical Positions Detected**: Rate of critical positions being identified

#### Dedicated Automation Dashboard (`automation-monitoring.json`)
- **Comprehensive Automation Metrics**: Detailed view of all automation KPIs
- **Upkeep Performance**: Performance metrics for Chainlink upkeep
- **Automation Events Timeline**: Historical view of automation events
- **Alert Status**: Current alert status and notifications

#### Automation Alerts Dashboard (`automation-alerts.json`)
- **Active Alerts**: Currently firing alerts
- **Alert History**: Historical alert data
- **Alert Rules Configuration**: Overview of configured alert rules

### 2. Prometheus Metrics

#### Core Automation Metrics
- `automation_healthy`: Health status of the automation system (0/1)
- `automation_triggers_total`: Total number of automation triggers
- `automation_delay_seconds`: Current delay in automation execution
- `automation_success_total`: Total successful automation executions
- `automation_failure_total`: Total failed automation executions

#### Position Monitoring Metrics
- `position_health_factor_critical_total`: Number of positions with critical health factors
- `position_liquidation_risk_high_total`: Number of positions at high liquidation risk

#### Performance Metrics
- `automation_execution_duration_seconds`: Time taken to execute automation
- `automation_gas_used_total`: Total gas used by automation
- `automation_upkeep_balance`: Current upkeep balance

### 3. Alert Rules

#### Critical Alerts
- **AutomationSystemDown**: Triggers when automation system is unhealthy
- **AutomationHighDelay**: Triggers when delay exceeds 10 minutes
- **AutomationHighFailureRate**: Triggers when success rate drops below 80%
- **HighCriticalPositions**: Triggers when too many critical positions are detected

#### Warning Alerts
- **AutomationNoTriggers**: Triggers when no automation occurs for 1 hour
- **AutomationModerateFailureRate**: Triggers when success rate drops below 95%
- **AutomationDelayIncreasing**: Triggers when delay is consistently increasing

#### Infrastructure Alerts
- **BackendAutomationDown**: Backend automation service is unavailable
- **SubgraphAutomationDown**: Subgraph automation service is unavailable
- **AutomationHighMemoryUsage**: High memory usage in automation components

## Setup Instructions

### 1. Start Monitoring Stack

```bash
# Start Prometheus and Grafana
docker-compose up -d prometheus grafana

# Verify services are running
docker-compose ps
```

### 2. Access Dashboards

- **Grafana**: http://localhost:3001
  - Username: `admin`
  - Password: `admin`
- **Prometheus**: http://localhost:9090

### 3. Import Dashboards

Dashboards are automatically provisioned when starting Grafana. You can find them under:
- "Watchtower Dashboard" - Main monitoring dashboard
- "Automation Monitoring" - Detailed automation metrics
- "Automation Alerts" - Alert management and history

### 4. Configure Notifications

To receive alerts, configure notification channels in Grafana:

1. Go to Alerting → Notification channels
2. Add channels for:
   - Slack (for team notifications)
   - Email (for critical alerts)
   - Webhook (for integration with other systems)

## Key Metrics to Monitor

### 1. System Health
- **Automation Health Status**: Should always be "HEALTHY" (1)
- **Service Uptime**: All automation services should be up

### 2. Performance
- **Automation Delay**: Should be < 5 minutes under normal conditions
- **Success Rate**: Should be > 95% under normal conditions
- **Trigger Rate**: Should correlate with position activity

### 3. Position Monitoring
- **Critical Positions**: Monitor for spikes indicating market stress
- **Liquidation Risk**: Track positions approaching liquidation

### 4. Resource Usage
- **Memory Usage**: Monitor for memory leaks
- **Gas Usage**: Track automation costs
- **Upkeep Balance**: Ensure sufficient funds for automation

## Troubleshooting

### High Automation Delay
1. Check Chainlink network status
2. Verify upkeep balance
3. Review gas price settings
4. Check for network congestion

### Low Success Rate
1. Review error logs in backend services
2. Check smart contract state
3. Verify price feed availability
4. Review automation conditions

### No Automation Triggers
1. Verify position monitoring is active
2. Check price feed updates
3. Review automation conditions
4. Verify upkeep registration

### Service Down Alerts
1. Check Docker container status
2. Review service logs
3. Verify network connectivity
4. Check resource availability

## Best Practices

### 1. Regular Monitoring
- Check dashboards daily
- Review alert history weekly
- Monitor trends over time

### 2. Alert Management
- Acknowledge alerts promptly
- Document resolution steps
- Review and tune alert thresholds

### 3. Performance Optimization
- Monitor gas usage trends
- Optimize automation conditions
- Regular upkeep balance management

### 4. Incident Response
- Have escalation procedures
- Maintain runbooks for common issues
- Regular disaster recovery testing

## Integration with External Systems

### Slack Integration
```json
{
  "url": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
  "channel": "#derisk-alerts",
  "title": "DeRisk Automation Alert",
  "text": "{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}"
}
```

### Email Integration
```json
{
  "addresses": ["team@derisk.com"],
  "subject": "DeRisk Automation Alert: {{ .GroupLabels.alertname }}",
  "body": "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}"
}
```

### Webhook Integration
```json
{
  "url": "https://api.derisk.com/alerts",
  "httpMethod": "POST",
  "title": "Automation Alert",
  "message": "{{ .CommonAnnotations.summary }}"
}
```

## Maintenance

### Regular Tasks
- Update dashboard configurations
- Review and tune alert thresholds
- Clean up old metric data
- Update notification channels

### Monthly Reviews
- Analyze automation performance trends
- Review alert effectiveness
- Update documentation
- Plan capacity improvements

For more information, refer to the [Chainlink Automation Documentation](https://docs.chain.link/chainlink-automation).