# TerraCloud Performance Testing Guide

## Quick Start

This guide will help you execute performance tests for the TerraCloud IaaS vs PaaS comparison project.

---

## Prerequisites

### Required Software
```bash
# Node.js (v16 or higher)
node --version

# Artillery.js
npm install -g artillery@latest

# Verify installation
artillery --version
# Should show: Artillery 2.x.x
```

### Azure Requirements
- Active Azure subscription
- IaaS deployment (VMs) running and accessible
- PaaS deployment (App Service) running and accessible
- Azure CLI installed (for metrics collection)

### Network Requirements
- Stable internet connection
- Access to target URLs
- No firewall blocking outgoing HTTP/HTTPS traffic

---

## Project Structure

```
tests/performance/
├── scenarios/              # Test scenario definitions
│   ├── normal-load.yml    # Normal load test (baseline)
│   ├── stress-test.yml    # Stress test (high load)
│   └── spike-test.yml     # Spike test (sudden surges)
├── configs/               # Configuration files
│   ├── iaas-config.yml    # IaaS-specific settings
│   ├── paas-config.yml    # PaaS-specific settings
│   └── test-data.csv      # Sample test data
├── processors/            # Custom Artillery functions
│   └── custom-functions.js
└── README.md             # This file
```

---

## Configuration

### Step 1: Set Environment Variables

**For IaaS Testing:**
```bash
# Windows (Command Prompt)
set IAAS_URL=http://your-iaas-loadbalancer.eastus.cloudapp.azure.com
set INFRASTRUCTURE_TYPE=IaaS
set TEST_RUN_ID=iaas-20250107-001

# Windows (PowerShell)
$env:IAAS_URL="http://your-iaas-loadbalancer.eastus.cloudapp.azure.com"
$env:INFRASTRUCTURE_TYPE="IaaS"
$env:TEST_RUN_ID="iaas-20250107-001"

# Linux/Mac
export IAAS_URL="http://your-iaas-loadbalancer.eastus.cloudapp.azure.com"
export INFRASTRUCTURE_TYPE="IaaS"
export TEST_RUN_ID="iaas-20250107-001"
```

**For PaaS Testing:**
```bash
# Windows (Command Prompt)
set PAAS_URL=https://terracloud-paas.azurewebsites.net
set INFRASTRUCTURE_TYPE=PaaS
set TEST_RUN_ID=paas-20250107-001

# Windows (PowerShell)
$env:PAAS_URL="https://terracloud-paas.azurewebsites.net"
$env:INFRASTRUCTURE_TYPE="PaaS"
$env:TEST_RUN_ID="paas-20250107-001"

# Linux/Mac
export PAAS_URL="https://terracloud-paas.azurewebsites.net"
export INFRASTRUCTURE_TYPE="PaaS"
export TEST_RUN_ID="paas-20250107-001"
```

### Step 2: Update Configuration Files

**Update `configs/iaas-config.yml`:**
- Replace `{{ $processEnvironment.IAAS_URL }}` placeholder with actual URL if not using environment variables
- Update VM configuration details in comments

**Update `configs/paas-config.yml`:**
- Replace `{{ $processEnvironment.PAAS_URL }}` placeholder with actual URL if not using environment variables
- Update App Service configuration details in comments

### Step 3: Customize Test Scenarios (Optional)

Edit scenario files to match your application's endpoints:
- `scenarios/normal-load.yml`
- `scenarios/stress-test.yml`
- `scenarios/spike-test.yml`

**Example: Update endpoints to match your app:**
```yaml
scenarios:
  - name: "Homepage Load Test"
    flow:
      - get:
          url: "/"              # Your homepage
      - get:
          url: "/api/health"    # Your health endpoint
      - post:
          url: "/api/data"      # Your API endpoint
```

---

## Running Tests

### Quick Test Commands

**Test IaaS - Normal Load:**
```bash
artillery run -e iaas scenarios/normal-load.yml
```

**Test PaaS - Normal Load:**
```bash
artillery run -e paas scenarios/normal-load.yml
```

### Full Test Suite with Output Capture

**IaaS Complete Test Suite:**
```bash
# Create results directory
mkdir -p results

# Normal load test
artillery run -e iaas scenarios/normal-load.yml \
  --output results/iaas-normal-$(date +%Y%m%d-%H%M%S).json

# Wait 30 minutes for system stabilization
# (On Windows: timeout /t 1800)
sleep 1800

# Stress test
artillery run -e iaas scenarios/stress-test.yml \
  --output results/iaas-stress-$(date +%Y%m%d-%H%M%S).json

# Wait 30 minutes
sleep 1800

# Spike test
artillery run -e iaas scenarios/spike-test.yml \
  --output results/iaas-spike-$(date +%Y%m%d-%H%M%S).json
```

**PaaS Complete Test Suite:**
```bash
# Normal load test
artillery run -e paas scenarios/normal-load.yml \
  --output results/paas-normal-$(date +%Y%m%d-%H%M%S).json

# Wait 30 minutes
sleep 1800

# Stress test
artillery run -e paas scenarios/stress-test.yml \
  --output results/paas-stress-$(date +%Y%m%d-%H%M%S).json

# Wait 30 minutes
sleep 1800

# Spike test
artillery run -e paas scenarios/spike-test.yml \
  --output results/paas-spike-$(date +%Y%m%d-%H%M%S).json
```

### Windows-Specific Commands

```cmd
REM Create results directory
mkdir results

REM Run IaaS normal load test
artillery run -e iaas scenarios/normal-load.yml --output results/iaas-normal-%date:~-4,4%%date:~-10,2%%date:~-7,2%.json

REM Wait 30 minutes (1800 seconds)
timeout /t 1800

REM Run stress test
artillery run -e iaas scenarios/stress-test.yml --output results/iaas-stress-%date:~-4,4%%date:~-10,2%%date:~-7,2%.json
```

---

## Generating Reports

### HTML Reports

Artillery can generate HTML reports from JSON output:

```bash
# Generate report from saved JSON
artillery report results/iaas-normal-20250107-120000.json

# This creates: results/iaas-normal-20250107-120000.json.html
```

### Real-time Monitoring

Run with real-time console output (no need to wait for completion):

```bash
artillery run -e iaas scenarios/normal-load.yml
```

---

## Understanding Test Results

### Key Metrics Explained

**Response Time Metrics:**
- `min`: Fastest response time
- `max`: Slowest response time
- `median`: 50th percentile (half of requests faster, half slower)
- `p95`: 95th percentile (95% of requests were faster than this)
- `p99`: 99th percentile (99% of requests were faster than this)

**Throughput Metrics:**
- `scenarios.completed`: Number of complete user scenarios executed
- `scenarios.created`: Number of virtual users created
- `http.requests`: Total number of HTTP requests sent
- `http.responses`: Total number of responses received
- `vusers.completed`: Virtual users that completed successfully

**Error Metrics:**
- `http.codes.2xx`: Successful responses
- `http.codes.4xx`: Client errors (bad requests)
- `http.codes.5xx`: Server errors (system overload/failures)
- `errors.*`: Various error types

### Sample Output Interpretation

```
Summary report @ 12:34:56(+0000)
  Scenarios launched:  600
  Scenarios completed: 595
  Requests completed:  2380
  Mean response/sec: 39.67
  Response time (msec):
    min: 45
    max: 1234
    median: 187
    p95: 456
    p99: 789
  Codes:
    200: 2350
    500: 30
```

**Interpretation:**
- 99.2% scenario completion rate (595/600)
- ~40 requests per second throughput
- Median response time: 187ms (acceptable)
- p95: 456ms (acceptable under 1000ms threshold)
- 1.26% error rate (30/2380) - within acceptable limits

---

## Troubleshooting

### Common Issues

**Issue: "ECONNREFUSED" errors**
```
Solution:
- Verify target URL is correct and accessible
- Check if application is running
- Test URL manually in browser first: curl $IAAS_URL
```

**Issue: "Cannot find module" error**
```
Solution:
- Ensure Artillery is installed globally: npm install -g artillery
- Or run from project directory with local install: npx artillery run ...
```

**Issue: Very high error rates (>10%)**
```
Solution:
- System may be overwhelmed - reduce load in test scenario
- Check Azure portal for resource constraints
- Verify application logs for errors
- May need to scale up resources before testing
```

**Issue: Tests timing out**
```
Solution:
- Increase timeout in scenario config files
- Check network connectivity
- Verify application is responding (not crashed)
```

**Issue: Inconsistent results between test runs**
```
Solution:
- Ensure proper stabilization period between tests
- Clear application caches/restart between runs
- Check for background processes affecting Azure resources
- Run tests at consistent times of day
```

### Debug Mode

Run Artillery with debug output:

```bash
# Enable debug logging
DEBUG=http artillery run -e iaas scenarios/normal-load.yml

# Or more verbose
DEBUG=* artillery run -e iaas scenarios/normal-load.yml
```

---

## Best Practices

### Before Running Tests

1. **Notify the Team**
   - Schedule tests in advance
   - Inform team members to avoid manual changes during tests

2. **Verify System Health**
   ```bash
   # Test IaaS endpoint
   curl http://your-iaas-url.com/api/health

   # Test PaaS endpoint
   curl https://your-paas-url.azurewebsites.net/api/health
   ```

3. **Clear Metrics**
   - Reset Azure Monitor metrics or note start time
   - Clear application logs

4. **Document Configuration**
   - Note VM sizes, count, configuration
   - Note App Service plan and settings

### During Tests

1. **Monitor Progress**
   - Watch Artillery console output
   - Monitor Azure portal for resource usage
   - Check for unexpected errors

2. **Don't Interrupt**
   - Let tests complete fully
   - Interrupted tests invalidate results

3. **Take Notes**
   - Document any anomalies
   - Note Azure alerts or warnings
   - Screenshot interesting metrics

### After Tests

1. **Save All Data**
   - Artillery JSON output
   - Azure Monitor metrics
   - Application logs
   - Cost data

2. **Wait Between Tests**
   - 30 minutes minimum between scenarios
   - 1-2 hours between IaaS and PaaS testing

3. **Generate Reports**
   - Create HTML reports immediately
   - Document observations while fresh

---

## Cost Monitoring

### Track Test Costs

```bash
# Azure CLI - Get cost data
az consumption usage list \
  --start-date 2025-01-07 \
  --end-date 2025-01-08 \
  --query "[?contains(instanceName, 'terracloud')]" \
  --output table

# Or use Azure Portal:
# Cost Management + Billing > Cost Analysis
```

### Estimate Costs Before Testing

**Typical Test Costs:**
- IaaS (2x Standard_B2s VMs): ~$0.08-0.10/hour
- PaaS (Standard S1 App Service): ~$0.10/hour
- Full test suite (6 hours total): ~$0.50-0.60

**Budget Recommendation:**
- Set Azure spending alert at $5
- Monitor costs daily during testing period

---

## Collecting Azure Metrics

### Using Azure Portal

1. Navigate to your resource (VM or App Service)
2. Click "Metrics" in left sidebar
3. Select time range matching your test
4. Add metrics: CPU, Memory, Network
5. Click "Download to Excel" to save data

### Using Azure CLI

```bash
# Get VM metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm}" \
  --metric "Percentage CPU" \
  --start-time 2025-01-07T12:00:00Z \
  --end-time 2025-01-07T13:00:00Z \
  --interval PT1M \
  --output table

# Get App Service metrics
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app}" \
  --metric "CpuPercentage" \
  --start-time 2025-01-07T12:00:00Z \
  --end-time 2025-01-07T13:00:00Z \
  --interval PT1M \
  --output table
```

---

## Team Coordination

### Test Schedule Template

**Announce to team:**
```
Subject: Performance Testing Schedule - TerraCloud

Team,

I will be running performance tests on the following schedule:

Date: January 7, 2025
Time: 14:00-20:00 UTC

IaaS Testing: 14:00-17:00
  - Normal Load: 14:00-14:15
  - Stress Test: 14:45-15:15
  - Spike Test: 15:45-16:15

PaaS Testing: 17:00-20:00
  - Normal Load: 17:00-17:15
  - Stress Test: 17:45-18:15
  - Spike Test: 18:45-19:15

Please:
- Do not make changes to infrastructure during this time
- Do not deploy application updates
- Do not run manual tests

I will share results by January 8.

Thanks,
Syrine
```

### Dependencies

**Information needed from team:**
- Eloi Terrol: IaaS URL, VM configuration details
- Axel Bacquet: PaaS URL, application deployment status
- Hanene Triaa: Final approval to run tests

---

## Advanced Usage

### Custom Test Scenarios

Create your own test scenario:

```yaml
config:
  target: "{{ $processEnvironment.TARGET_URL }}"
  phases:
    - duration: 300
      arrivalRate: 20
      name: "Custom test"

scenarios:
  - name: "My Custom Scenario"
    flow:
      - get:
          url: "/my/endpoint"
      - think: 2
      - post:
          url: "/my/api"
          json:
            data: "test"
```

Save as `scenarios/custom-test.yml` and run:
```bash
artillery run -e iaas scenarios/custom-test.yml
```

### Using Artillery Plugins

Install additional plugins for enhanced reporting:

```bash
# Install metrics plugin
npm install -g artillery-plugin-metrics-by-endpoint

# Install expect plugin for assertions
npm install -g artillery-plugin-expect
```

---

## Quick Reference

### Essential Commands

```bash
# Run a test
artillery run -e iaas scenarios/normal-load.yml

# Run with output save
artillery run -e iaas scenarios/normal-load.yml --output results/test.json

# Generate HTML report
artillery report results/test.json

# Quick test (1 user, 1 request)
artillery quick --count 1 --num 1 http://your-url.com

# Validate syntax
artillery run --validate scenarios/normal-load.yml
```

### Environment Variables Quick Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `IAAS_URL` | IaaS target URL | `http://iaas-lb.eastus.cloudapp.azure.com` |
| `PAAS_URL` | PaaS target URL | `https://app.azurewebsites.net` |
| `INFRASTRUCTURE_TYPE` | Test label | `IaaS` or `PaaS` |
| `TEST_RUN_ID` | Unique test identifier | `iaas-20250107-001` |

---

## Getting Help

### Documentation
- Artillery Docs: https://www.artillery.io/docs
- Azure Monitor: https://docs.microsoft.com/azure/azure-monitor/
- TerraCloud Strategy: `docs/performance-plan/strategy.md`
- Comparison Methodology: `docs/performance-plan/COMPARISON_METHODOLOGY.md`

### Team Contacts
- Syrine Ladhari (Testing): Primary contact for test execution
- Eloi Terrol (Infrastructure): IaaS environment questions
- Axel Bacquet (Application): Application and deployment questions
- Hanene Triaa (Team Lead): Overall coordination and approval

### Common Questions

**Q: How long does each test take?**
A: Normal load: 10 min, Stress test: 15 min, Spike test: 10 min + 30 min stabilization between each

**Q: Can I stop a test early?**
A: Yes, press Ctrl+C, but results won't be valid for comparison

**Q: How many times should I run each test?**
A: At least once for each scenario, ideally 2-3 times for consistency validation

**Q: What if results are very different from expectations?**
A: Document observations, verify configuration, and run test again after stabilization period

---

**Last Updated**: 2025-10-07
**Version**: 1.0
**Maintainer**: Syrine Ladhari
