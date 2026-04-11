interface MatchScoreRingProps {
  score: number;
  size?: number;
  strokeWidth?: number;
  fontSize?: string;
}

export function MatchScoreRing({
  score,
  size = 60,
  strokeWidth = 5,
  fontSize = "text-sm",
}: MatchScoreRingProps) {
  const radius = (size - strokeWidth * 2) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (score / 100) * circumference;

  const getColor = (score: number) => {
    if (score >= 75) return "#198038";
    if (score >= 50) return "#051DDA";
    if (score >= 30) return "#D97706";
    return "#9CA3AF";
  };

  const color = getColor(score);

  return (
    <div className="relative flex items-center justify-center" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="#E5E7EB"
          strokeWidth={strokeWidth}
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          strokeLinecap="round"
          style={{ transition: "stroke-dashoffset 0.8s ease" }}
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className={`${fontSize} font-bold`} style={{ color }}>
          {score}%
        </span>
      </div>
    </div>
  );
}
