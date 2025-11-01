# Enterprise Project Templates

## 🎯 Overview

This collection provides enterprise-grade project templates with:
- **Automated CI/CD Pipeline** with GitHub Actions
- **Change Control System** with branch protection
- **Quality Gates** (TypeScript, ESLint, Security, Testing)
- **Automated Deployment** scripts for solo developers
- **Comprehensive Documentation** templates
- **IDE-Agnostic** automation

## 📁 Template Structure

```
enterprise-templates/
├── project-starter/           # Complete project template
│   ├── README.md              # Project overview and setup
│   ├── package-template.json  # Package.json with automation
│   └── ...                    # All project files
├── change-control/            # Change control templates
│   └── pipeline-template.yml  # GitHub Actions CI/CD
├── automation/               # Automation script templates
│   ├── deploy-template.sh    # Deployment automation
│   ├── promote-template.sh   # Branch promotion
│   └── configure-project.sh  # Project configuration
├── documentation/            # Documentation templates
│   ├── CHANGELOG-template.md  # Changelog template
│   ├── README-template.md     # README template
│   └── ...                    # Other documentation
└── README.md                 # This file
```

## 🚀 Quick Start

### **Option 1: Use Complete Project Template**
```bash
# Copy entire project template
cp -r /Users/rosssivertsen/dev/enterprise-templates/project-starter/* /path/to/new-project/
cd /path/to/new-project/

# Configure project
./scripts/configure-project.sh

# Start development
npm run dev
```

### **Option 2: Use Individual Templates**
```bash
# Copy specific templates
cp /Users/rosssivertsen/dev/enterprise-templates/change-control/pipeline-template.yml .github/workflows/ci-cd.yml
cp /Users/rosssivertsen/dev/enterprise-templates/automation/deploy-template.sh scripts/deploy.sh
cp /Users/rosssivertsen/dev/enterprise-templates/documentation/CHANGELOG-template.md CHANGELOG.md

# Make scripts executable
chmod +x scripts/*.sh
```

## 🔧 Template Components

### **1. Project Starter Template**
- Complete project structure
- All automation scripts
- Documentation templates
- GitHub Actions workflow
- Package.json with automation commands

### **2. Change Control Templates**
- GitHub Actions CI/CD pipeline
- Branch protection rules
- Quality gates configuration
- Automated testing setup
- Deployment automation

### **3. Automation Scripts**
- **deploy.sh**: Environment-specific deployment
- **promote.sh**: Branch promotion automation
- **quick-deploy.sh**: One-command deployment
- **configure-project.sh**: Project setup automation

### **4. Documentation Templates**
- **CHANGELOG.md**: Version history template
- **README.md**: Project documentation template
- **CONTRIBUTING.md**: Contribution guidelines
- **Technical docs**: Architecture and requirements

## 📋 Usage Examples

### **New Project Setup:**
```bash
# 1. Copy template
cp -r /Users/rosssivertsen/dev/enterprise-templates/project-starter/* my-new-project/
cd my-new-project/

# 2. Configure project
./scripts/configure-project.sh

# 3. Push to GitHub
git push -u origin main

# 4. Start development
npm run dev
```

### **Add to Existing Project:**
```bash
# 1. Copy automation scripts
cp /Users/rosssivertsen/dev/enterprise-templates/automation/*.sh scripts/
chmod +x scripts/*.sh

# 2. Copy GitHub Actions workflow
mkdir -p .github/workflows
cp /Users/rosssivertsen/dev/enterprise-templates/change-control/pipeline-template.yml .github/workflows/ci-cd.yml

# 3. Update package.json with automation commands
# (Copy from /Users/rosssivertsen/dev/enterprise-templates/project-starter/package-template.json)

# 4. Add documentation templates
cp /Users/rosssivertsen/dev/enterprise-templates/documentation/*.md docs/
```

## 🎯 Automation Commands

### **Deployment Commands:**
```bash
npm run deploy              # Quick deploy (auto-promotes)
npm run pipeline:full       # Full pipeline (dev → staging → prod)
npm run pipeline:direct     # Direct deployment (dev → prod)
npm run promote:staging     # Promote to staging
npm run promote:production  # Promote to production
```

### **Quality Commands:**
```bash
npm run build               # Production build
npm run lint                # Code quality check
npm run test                # Run tests
npm run security            # Security audit
npm run type-check          # TypeScript validation
```

### **Setup Commands:**
```bash
npm run setup               # Configure project
npm run init-github         # Set up GitHub repository
npm run init-change-control # Initialize change control
```

## 🌿 Branch Strategy

### **Branch Hierarchy:**
```
main (Production) ← staging (UAT) ← development (Integration)
    ↑                    ↑                    ↑
hotfix/*            feature/*           bugfix/*
```

### **Branch Protection Rules:**
- **main**: 2 reviews required, 4 status checks, no force push
- **staging**: 1 review required, 3 status checks, emergency bypass
- **development**: 1 review required, 2 status checks, force push allowed

## 🤖 Quality Gates

### **Automated Checks:**
- TypeScript compilation
- ESLint analysis
- Security audit
- Build verification
- Test execution
- Coverage reporting

### **Pre-deployment Validation:**
- Code quality validation
- Security vulnerability scan
- Performance testing
- Integration testing
- Environment-specific builds

## 📚 Documentation Templates

### **Technical Documentation:**
- Architecture and requirements
- API documentation
- Testing strategies
- Deployment procedures
- Change control processes

### **User Documentation:**
- Getting started guides
- User manuals
- Troubleshooting guides
- FAQ sections

## 🔒 Security & Compliance

### **Security Features:**
- Automated security audits
- Dependency vulnerability scanning
- Secret scanning prevention
- Input validation and sanitization

### **Compliance Features:**
- Audit trail for all changes
- Branch protection enforcement
- Code review requirements
- Deployment approval workflows

## 🚀 Advanced Features

### **Solo Developer Optimizations:**
- One-command deployment
- Automatic branch promotion
- Quality gate automation
- Error handling and rollback

### **Team Collaboration:**
- Code review workflows
- Branch protection rules
- Automated testing
- Documentation generation

## 📞 Support

### **Template Usage:**
1. Check the individual template README files
2. Review the automation scripts
3. Examine the GitHub Actions workflows
4. Refer to the documentation templates

### **Customization:**
- Update project-specific variables in scripts
- Modify GitHub Actions workflows for your deployment
- Customize documentation templates
- Add project-specific quality gates

## 🏆 Benefits

### **Development Velocity:**
- Automated quality checks
- One-command deployment
- Instant feedback on issues
- Streamlined workflow

### **Code Quality:**
- Enforced coding standards
- Automated testing
- Security scanning
- Performance monitoring

### **Risk Mitigation:**
- Branch protection
- Code review requirements
- Automated rollback
- Audit trail

---

**These templates provide enterprise-grade project management with solo developer efficiency!** 🚀
---

## 🆕 NEW: Multiple CI/CD Templates

The `change-control/` directory now includes templates for different project types:

### **Available CI/CD Templates:**

1. **pipeline-nodejs-template.yml** (Original)
   - For Node.js/TypeScript projects
   - Includes: npm, TypeScript, ESLint, testing, security audit

2. **pipeline-python-template.yml** (NEW)
   - For Python projects
   - Includes: pip, syntax checks, pytest, linting (optional)

3. **pipeline-generic-template.yml** (NEW)
   - For any project type
   - Minimal template - customize as needed

### **Quick Template Selection:**

```bash
# For Python projects
cp ~/dev/enterprise-templates/change-control/pipeline-python-template.yml .github/workflows/ci-cd.yml

# For Node.js projects
cp ~/dev/enterprise-templates/change-control/pipeline-nodejs-template.yml .github/workflows/ci-cd.yml

# For other projects
cp ~/dev/enterprise-templates/change-control/pipeline-generic-template.yml .github/workflows/ci-cd.yml
```

**See `change-control/README.md` for detailed documentation on each template.**

---
