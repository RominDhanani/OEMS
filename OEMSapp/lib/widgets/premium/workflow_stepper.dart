import 'package:flutter/material.dart';

enum WorkflowStage {
  draft,
  pendingApproval,
  approved,
  receiptApproved,
  expansionRequested,
  fundAllocated,
  completed
}

class WorkflowStepper extends StatelessWidget {
  final String currentStatus;
  final bool isRejected;

  const WorkflowStepper({
    super.key,
    required this.currentStatus,
    this.isRejected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Map status to stage
    final stage = _mapStatusToStage(currentStatus);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isRejected ? Colors.red : theme.primaryColor).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isRejected ? Icons.error_outline : Icons.alt_route_rounded,
                  size: 18,
                  color: isRejected ? Colors.red : theme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isRejected ? "PROCESS HALTED" : "WORKFLOW PROGRESS",
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 11,
                  color: isRejected ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStep(context, "Draft", WorkflowStage.draft, stage),
              _buildConnector(context, WorkflowStage.draft, stage),
              _buildStep(context, "Review", WorkflowStage.pendingApproval, stage),
              _buildConnector(context, WorkflowStage.pendingApproval, stage),
              _buildStep(context, "Approved", WorkflowStage.approved, stage),
              _buildConnector(context, WorkflowStage.approved, stage),
              _buildStep(context, "Funded", WorkflowStage.fundAllocated, stage),
              _buildConnector(context, WorkflowStage.fundAllocated, stage),
              _buildStep(context, "Done", WorkflowStage.completed, stage),
            ],
          ),
        ],
      ),
    );
  }

  WorkflowStage _mapStatusToStage(String status) {
    status = status.toUpperCase();
    switch (status) {
      case 'PENDING_APPROVAL':
      case 'PENDING':
        return WorkflowStage.pendingApproval;
      case 'APPROVED':
        return WorkflowStage.approved;
      case 'RECEIPT_APPROVED':
        return WorkflowStage.receiptApproved;
      case 'EXPANSION_REQUESTED':
        return WorkflowStage.expansionRequested;
      case 'FUND_ALLOCATED':
      case 'EXPANSION_ALLOCATED':
        return WorkflowStage.fundAllocated;
      case 'COMPLETED':
      case 'FUND_CONFIRMED':
        return WorkflowStage.completed;
      default:
        return WorkflowStage.draft;
    }
  }

  Widget _buildStep(BuildContext context, String label, WorkflowStage stepStage, WorkflowStage currentStage) {
    final theme = Theme.of(context);
    final isCompleted = stepStage.index < currentStage.index;
    final isActive = stepStage == currentStage;

    Color iconColor;
    if (isRejected && isActive) {
      iconColor = Colors.red;
    } else if (isCompleted) {
      iconColor = const Color(0xFF10B981); // Success Green
    } else if (isActive) {
      iconColor = theme.brightness == Brightness.dark ? theme.colorScheme.secondary : theme.primaryColor;
    } else {
      iconColor = theme.colorScheme.onSurface.withOpacity(0.85);
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isActive 
              ? iconColor.withOpacity(0.12) 
              : theme.colorScheme.onSurface.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive 
                ? iconColor 
                : (isCompleted ? iconColor.withOpacity(0.55) : theme.colorScheme.onSurface.withOpacity(0.25)),
              width: isActive ? 2.2 : 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              isRejected && isActive 
                ? Icons.close
                : (isCompleted ? Icons.check : _getStageIcon(stepStage)),
              size: isCompleted ? 18 : 16,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isActive ? iconColor : theme.colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(BuildContext context, WorkflowStage before, WorkflowStage current) {
    final isCompleted = before.index < current.index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isCompleted 
              ? const Color(0xFF10B981).withOpacity(0.65) 
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  IconData _getStageIcon(WorkflowStage stage) {
    switch (stage) {
      case WorkflowStage.draft: return Icons.edit_note_rounded;
      case WorkflowStage.pendingApproval: return Icons.pending_actions_rounded;
      case WorkflowStage.approved: return Icons.fact_check_rounded;
      case WorkflowStage.receiptApproved: return Icons.receipt_rounded;
      case WorkflowStage.expansionRequested: return Icons.rocket_launch_rounded;
      case WorkflowStage.fundAllocated: return Icons.payments_rounded;
      case WorkflowStage.completed: return Icons.task_alt_rounded;
    }
  }
}

