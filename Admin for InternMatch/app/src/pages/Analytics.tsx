import { useEffect, useState } from 'react';
import {
  TrendingUp,
  MapPin,
  DollarSign,
  Filter,
  Users,
  Building2,
  GraduationCap,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { analyticsApi } from '@/services/api';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  AreaChart,
  Area,
} from 'recharts';
import { toast } from 'sonner';

export function Analytics() {
  const [domainTrends, setDomainTrends] = useState<any[]>([]);
  const [locationHeatmap, setLocationHeatmap] = useState<any[]>([]);
  const [stipendDistribution, setStipendDistribution] = useState<any[]>([]);
  const [applicationFunnel, setApplicationFunnel] = useState<any[]>([]);
  const [topInternships, setTopInternships] = useState<any[]>([]);
  const [domainMatchScores, setDomainMatchScores] = useState<any[]>([]);
  const [collegeApplications, setCollegeApplications] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const [
        domainTrendsData,
        locationData,
        stipendData,
        funnelData,
        topInternshipsData,
        matchScoresData,
        collegeData,
      ] = await Promise.all([
        analyticsApi.getDomainTrends(),
        analyticsApi.getLocationHeatmap(),
        analyticsApi.getStipendDistribution(),
        analyticsApi.getApplicationFunnel(),
        analyticsApi.getTopInternships(),
        analyticsApi.getDomainMatchScores(),
        analyticsApi.getCollegeApplications(),
      ]);

      setDomainTrends(domainTrendsData);
      setLocationHeatmap(locationData);
      setStipendDistribution(stipendData);
      setApplicationFunnel(funnelData);
      setTopInternships(topInternshipsData);
      setDomainMatchScores(matchScoresData);
      setCollegeApplications(collegeData);
    } catch (error) {
      toast.error('Failed to fetch analytics data');
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Analytics</h1>
        <p className="text-muted-foreground mt-1">
          Deep-dive analytics and insights about the platform.
        </p>
      </div>

      {/* Domain Trends */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <TrendingUp className="h-5 w-5" />
            Domain-wise Listing Count Over Time
          </CardTitle>
          <CardDescription>
            Monthly trend of internship listings by domain.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={350}>
            <AreaChart data={domainTrends}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="date" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'white',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px',
                }}
              />
              <Area
                type="monotone"
                dataKey="Software Engineering"
                stackId="1"
                stroke="#3b82f6"
                fill="#3b82f6"
                fillOpacity={0.6}
              />
              <Area
                type="monotone"
                dataKey="Data Science"
                stackId="1"
                stroke="#10b981"
                fill="#10b981"
                fillOpacity={0.6}
              />
              <Area
                type="monotone"
                dataKey="Product Management"
                stackId="1"
                stroke="#f59e0b"
                fill="#f59e0b"
                fillOpacity={0.6}
              />
              <Area
                type="monotone"
                dataKey="UI/UX Design"
                stackId="1"
                stroke="#8b5cf6"
                fill="#8b5cf6"
                fillOpacity={0.6}
              />
              <Area
                type="monotone"
                dataKey="Marketing"
                stackId="1"
                stroke="#ec4899"
                fill="#ec4899"
                fillOpacity={0.6}
              />
            </AreaChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Two Column Layout */}
      <div className="grid gap-4 md:grid-cols-2">
        {/* Location Heatmap */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MapPin className="h-5 w-5" />
              Listings by Location
            </CardTitle>
            <CardDescription>
              Top cities by number of internship listings.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={locationHeatmap} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis type="number" tick={{ fontSize: 12 }} />
                <YAxis
                  dataKey="city"
                  type="category"
                  tick={{ fontSize: 12 }}
                  width={80}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'white',
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px',
                  }}
                />
                <Bar dataKey="count" fill="#3b82f6" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Stipend Distribution */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <DollarSign className="h-5 w-5" />
              Stipend Distribution by Domain
            </CardTitle>
            <CardDescription>
              Median stipend range across different domains.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={stipendDistribution}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="domain" tick={{ fontSize: 11 }} angle={-45} textAnchor="end" height={80} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'white',
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px',
                  }}
                  formatter={(value: number) => `₹${value.toLocaleString()}`}
                />
                <Bar dataKey="min" stackId="a" fill="#e5e7eb" />
                <Bar dataKey="q1" stackId="a" fill="#93c5fd" />
                <Bar dataKey="median" stackId="a" fill="#3b82f6" />
                <Bar dataKey="q3" stackId="a" fill="#2563eb" />
                <Bar dataKey="max" stackId="a" fill="#1d4ed8" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Application Funnel */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Filter className="h-5 w-5" />
            Application Funnel
          </CardTitle>
          <CardDescription>
            Conversion rates from application to acceptance.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-4 gap-4">
            {applicationFunnel.map((stage, index) => {
              const prevCount = index > 0 ? applicationFunnel[index - 1].count : stage.count;
              const conversionRate = index > 0 ? ((stage.count / prevCount) * 100).toFixed(1) : '100';
              
              return (
                <div key={stage.stage} className="relative">
                  <div className="bg-primary/10 rounded-lg p-6 text-center">
                    <div className="text-3xl font-bold text-primary">{stage.count.toLocaleString()}</div>
                    <div className="text-sm text-muted-foreground mt-1">{stage.stage}</div>
                    {index > 0 && (
                      <div className="text-xs text-green-600 mt-2">
                        {conversionRate}% conversion
                      </div>
                    )}
                  </div>
                  {index < applicationFunnel.length - 1 && (
                    <div className="absolute top-1/2 -right-2 transform -translate-y-1/2 text-muted-foreground">
                      →
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Two Column Layout */}
      <div className="grid gap-4 md:grid-cols-2">
        {/* Top Internships */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Building2 className="h-5 w-5" />
              Top 10 Most Applied Internships
            </CardTitle>
            <CardDescription>
              Internships with the highest number of applications.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={topInternships} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis type="number" tick={{ fontSize: 12 }} />
                <YAxis
                  dataKey="company"
                  type="category"
                  tick={{ fontSize: 11 }}
                  width={80}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'white',
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px',
                  }}
                />
                <Bar dataKey="applicationCount" fill="#10b981" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Domain Match Scores */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Users className="h-5 w-5" />
              Average Match Score by Domain
            </CardTitle>
            <CardDescription>
              Mean match score for applications in each domain.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={domainMatchScores}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="domain" tick={{ fontSize: 11 }} angle={-45} textAnchor="end" height={80} />
                <YAxis tick={{ fontSize: 12 }} domain={[0, 100]} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'white',
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px',
                  }}
                  formatter={(value: number) => `${value.toFixed(1)}%`}
                />
                <Bar dataKey="averageScore" fill="#8b5cf6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* College Applications */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <GraduationCap className="h-5 w-5" />
            Application Volume by College
          </CardTitle>
          <CardDescription>
            Top colleges by number of student applications.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={collegeApplications}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="college" tick={{ fontSize: 11 }} angle={-45} textAnchor="end" height={80} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'white',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px',
                }}
              />
              <Bar dataKey="count" fill="#f59e0b" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  );
}
