import { useEffect, useState } from 'react';
import {
  Brain,
  Upload,
  Play,
  Database,
  BarChart3,
  FileText,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { Badge } from '@/components/ui/badge';
import { mlModelApi } from '@/services/api';
import type { ModelMetrics, FeatureImportance, DatasetInfo } from '@/types';
import { toast } from 'sonner';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { cn } from '@/lib/utils';

export function MLModel() {
  const [metrics, setMetrics] = useState<ModelMetrics | null>(null);
  const [featureImportance, setFeatureImportance] = useState<FeatureImportance[]>([]);
  const [datasets, setDatasets] = useState<DatasetInfo[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isTraining, setIsTraining] = useState(false);
  const [trainingProgress, setTrainingProgress] = useState(0);
  const [trainingMessage, setTrainingMessage] = useState('');
  const [isUploading, setIsUploading] = useState(false);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const [metricsData, featuresData, datasetsData] = await Promise.all([
        mlModelApi.getMetrics(),
        mlModelApi.getFeatureImportance(),
        mlModelApi.getDatasets(),
      ]);
      setMetrics(metricsData);
      setFeatureImportance(featuresData);
      setDatasets(datasetsData);
    } catch (error) {
      toast.error('Failed to fetch ML model data');
    } finally {
      setIsLoading(false);
    }
  };

  const handleRetrain = async () => {
    try {
      setIsTraining(true);
      setTrainingProgress(0);
      setTrainingMessage('Initializing training...');

      const { jobId } = await mlModelApi.retrainModel();

      // Poll for progress
      const interval = setInterval(async () => {
        const status = await mlModelApi.getRetrainStatus(jobId);
        setTrainingProgress(status.progress);
        setTrainingMessage(status.message);

        if (!status.isTraining) {
          clearInterval(interval);
          setIsTraining(false);
          toast.success('Model retrained successfully!');
          fetchData();
        }
      }, 2000);
    } catch (error) {
      toast.error('Failed to start retraining');
      setIsTraining(false);
    }
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.name.endsWith('.csv')) {
      toast.error('Please upload a CSV file');
      return;
    }

    setIsUploading(true);
    try {
      await mlModelApi.uploadDataset(file);
      toast.success('Dataset uploaded successfully');
      fetchData();
    } catch (error) {
      toast.error('Failed to upload dataset');
    } finally {
      setIsUploading(false);
    }
  };

  const getMetricColor = (value: number) => {
    if (value >= 85) return 'text-green-600';
    if (value >= 70) return 'text-yellow-600';
    return 'text-red-600';
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
        <h1 className="text-3xl font-bold tracking-tight">ML Model Panel</h1>
        <p className="text-muted-foreground mt-1">
          Monitor and manage the internship recommendation model.
        </p>
      </div>

      {/* Model Status Card */}
      <Card className="border-primary/20">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                <Brain className="h-5 w-5 text-primary" />
              </div>
              <div>
                <CardTitle>Model Status</CardTitle>
                <CardDescription>
                  Current version: {metrics?.version} • Last trained:{' '}
                  {metrics?.lastTrained
                    ? new Date(metrics.lastTrained).toLocaleDateString()
                    : 'N/A'}
                </CardDescription>
              </div>
            </div>
            <Badge className="bg-green-100 text-green-800">Active</Badge>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            <div>
              <div className="text-sm text-muted-foreground mb-1">Accuracy</div>
              <div className={cn('text-3xl font-bold', getMetricColor(metrics?.accuracy || 0))}>
                {metrics?.accuracy}%
              </div>
              <Progress value={metrics?.accuracy} className="h-2 mt-2" />
            </div>
            <div>
              <div className="text-sm text-muted-foreground mb-1">Precision</div>
              <div className={cn('text-3xl font-bold', getMetricColor(metrics?.precision || 0))}>
                {metrics?.precision}%
              </div>
              <Progress value={metrics?.precision} className="h-2 mt-2" />
            </div>
            <div>
              <div className="text-sm text-muted-foreground mb-1">Recall</div>
              <div className={cn('text-3xl font-bold', getMetricColor(metrics?.recall || 0))}>
                {metrics?.recall}%
              </div>
              <Progress value={metrics?.recall} className="h-2 mt-2" />
            </div>
            <div>
              <div className="text-sm text-muted-foreground mb-1">F1 Score</div>
              <div className={cn('text-3xl font-bold', getMetricColor(metrics?.f1Score || 0))}>
                {metrics?.f1Score}%
              </div>
              <Progress value={metrics?.f1Score} className="h-2 mt-2" />
            </div>
          </div>
          <div className="mt-6 p-4 bg-muted rounded-lg flex items-center gap-4">
            <Database className="h-5 w-5 text-muted-foreground" />
            <div>
              <div className="text-sm font-medium">Training Dataset Size</div>
              <div className="text-2xl font-bold">{metrics?.datasetSize.toLocaleString()} records</div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Actions */}
      <div className="grid gap-4 md:grid-cols-2">
        {/* Upload Dataset */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Upload className="h-5 w-5" />
              Upload New Dataset
            </CardTitle>
            <CardDescription>
              Upload a CSV file with 36 required columns to retrain the model.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="border-2 border-dashed border-border rounded-lg p-8 text-center">
              <input
                type="file"
                accept=".csv"
                onChange={handleFileUpload}
                className="hidden"
                id="dataset-upload"
              />
              <label
                htmlFor="dataset-upload"
                className="cursor-pointer flex flex-col items-center"
              >
                <div className="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center mb-4">
                  <Upload className="h-6 w-6 text-primary" />
                </div>
                <p className="text-sm font-medium">Click to upload CSV file</p>
                <p className="text-xs text-muted-foreground mt-1">
                  Maximum file size: 100MB
                </p>
              </label>
            </div>
            {isUploading && (
              <div className="mt-4 text-center">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary mx-auto"></div>
                <p className="text-sm text-muted-foreground mt-2">Uploading...</p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Retrain Model */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Play className="h-5 w-5" />
              Retrain Model
            </CardTitle>
            <CardDescription>
              Trigger model retraining with the latest dataset.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {isTraining ? (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Training in progress...</span>
                  <span className="text-sm text-muted-foreground">{trainingProgress}%</span>
                </div>
                <Progress value={trainingProgress} className="h-3" />
                <p className="text-sm text-muted-foreground">{trainingMessage}</p>
              </div>
            ) : (
              <div className="text-center py-6">
                <Button onClick={handleRetrain} size="lg" className="w-full">
                  <Play className="h-5 w-5 mr-2" />
                  Start Retraining
                </Button>
                <p className="text-xs text-muted-foreground mt-3">
                  This process may take 10-15 minutes depending on dataset size.
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Feature Importance */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BarChart3 className="h-5 w-5" />
            Feature Importance
          </CardTitle>
          <CardDescription>
            Top 15 features by importance from the trained Random Forest model.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart
              data={featureImportance}
              layout="vertical"
              margin={{ left: 100 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis type="number" tick={{ fontSize: 12 }} domain={[0, 0.2]} />
              <YAxis
                dataKey="feature"
                type="category"
                tick={{ fontSize: 12 }}
                width={120}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'white',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px',
                }}
                formatter={(value: number) => `${(value * 100).toFixed(1)}%`}
              />
              <Bar dataKey="importance" fill="#3b82f6" radius={[0, 4, 4, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Dataset History */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            Dataset History
          </CardTitle>
          <CardDescription>
            Previously uploaded training datasets.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-muted/50 border-b">
                <tr>
                  <th className="text-left p-4 text-sm font-medium">Filename</th>
                  <th className="text-left p-4 text-sm font-medium">Uploaded At</th>
                  <th className="text-left p-4 text-sm font-medium">Rows</th>
                  <th className="text-left p-4 text-sm font-medium">Columns</th>
                  <th className="text-left p-4 text-sm font-medium">Class Balance</th>
                </tr>
              </thead>
              <tbody>
                {datasets.map((dataset) => (
                  <tr key={dataset.id} className="border-b hover:bg-muted/50">
                    <td className="p-4">
                      <div className="flex items-center gap-2">
                        <FileText className="h-4 w-4 text-muted-foreground" />
                        <span className="font-medium">{dataset.filename}</span>
                      </div>
                    </td>
                    <td className="p-4">
                      {new Date(dataset.uploadedAt).toLocaleString()}
                    </td>
                    <td className="p-4">{dataset.rowCount.toLocaleString()}</td>
                    <td className="p-4">{dataset.columnCount}</td>
                    <td className="p-4">
                      <div className="flex items-center gap-2">
                        <Badge variant="outline" className="text-green-600">
                          {dataset.classBalance.recommended.toLocaleString()} Recommended
                        </Badge>
                        <Badge variant="outline" className="text-red-600">
                          {dataset.classBalance.notRecommended.toLocaleString()} Not Rec.
                        </Badge>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
