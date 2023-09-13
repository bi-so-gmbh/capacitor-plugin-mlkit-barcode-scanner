package com.biso.capacitor.plugins.mlkit.barcode.scanner;

import static com.biso.capacitor.plugins.mlkit.barcode.scanner.MLKitBarcodeScannerPlugin.SETTINGS;

import android.Manifest;
import android.Manifest.permission;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageButton;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts.RequestPermission;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.AspectRatio;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.Preview;
import androidx.camera.core.Preview.SurfaceProvider;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LiveData;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.common.util.concurrent.ListenableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class CaptureActivity extends AppCompatActivity {

  private final ExecutorService executor = Executors.newSingleThreadExecutor();
  private Camera camera;
  private ScannerSettings settings;
  private CameraOverlay cameraOverlay;
  private ImageAnalysis imageAnalysis;

  private final ActivityResultLauncher<String> requestPermissionLauncher =
      registerForActivityResult(new RequestPermission(), isGranted -> {
        if (Boolean.TRUE.equals(isGranted)) {
          startCamera();
        } else {
          finishWithError("NO_CAMERA_PERMISSION");
        }
      });

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    CameraManager cameraManager = (CameraManager) this.getSystemService(Context.CAMERA_SERVICE);
    try {
      if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY)
          || cameraManager.getCameraIdList().length == 0) {
        finishWithError("NO_CAMERA");
      }
    } catch (CameraAccessException e) {
      finishWithError("NO_CAMERA");
    }

    if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU) {
      settings = getIntent().getParcelableExtra(SETTINGS, ScannerSettings.class);
    } else {
      // noinspection deprecation
      settings = getIntent().getParcelableExtra(SETTINGS); // NOSONAR
    }

    setContentView(getResources().getIdentifier("capture_activity", "layout", getPackageName()));
    cameraOverlay = new CameraOverlay(this, settings);
    ConstraintLayout constraintLayout = findViewById(
        getResources().getIdentifier("topLayout", "id", getPackageName()));
    constraintLayout.addView(cameraOverlay);

    if (checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
      startCamera();
    } else {
      requestPermissionLauncher.launch(permission.CAMERA);
    }

    ImageButton torchButton = findViewById(
        getResources().getIdentifier("torch_button", "id", getPackageName()));

    torchButton.setOnClickListener(v -> {
      LiveData<Integer> flashState = camera.getCameraInfo().getTorchState();
      if (flashState.getValue() != null) {
        boolean state = flashState.getValue() == 1;
        torchButton.setBackgroundResource(
            getResources().getIdentifier(!state ? "torch_active" : "torch_inactive",
                "drawable", CaptureActivity.this.getPackageName()));
        camera.getCameraControl().enableTorch(!state);
      }
    });
  }

  private void finishWithError(String errorMessage) {
    Intent result = new Intent();
    result.putExtra("error", errorMessage);
    setResult(CommonStatusCodes.ERROR, result);
    if (imageAnalysis != null) {
      imageAnalysis.clearAnalyzer();
    }
    finish();
  }

  private void finishWithSuccess(Intent data) {
    setResult(CommonStatusCodes.SUCCESS, data);
    if (imageAnalysis != null) {
      imageAnalysis.clearAnalyzer();
    }
    finish();
  }

  void startCamera() {
    PreviewView previewView = findViewById(
        getResources().getIdentifier("previewView", "id", getPackageName()));
    previewView.setImplementationMode(PreviewView.ImplementationMode.COMPATIBLE);

    previewView.setScaleX(1F);
    previewView.setScaleY(1F);

    ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(
        this);
    cameraProviderFuture.addListener(() -> {
      try {
        CaptureActivity.this.bindPreview(cameraProviderFuture.get(),
            previewView.getSurfaceProvider());
      } catch (ExecutionException | InterruptedException e) { // NOSONAR
        // No errors need to be handled for this Future.
        // This should never be reached.
        Log.e("MLKitBarcodeScanner - Capture Activity", "Couldn't start camera");
      }
    }, ContextCompat.getMainExecutor(this));
  }

  /**
   * Binding to camera
   */
  private void bindPreview(ProcessCameraProvider cameraProvider, SurfaceProvider surfaceProvider) {
    Preview preview = new Preview.Builder().build();

    CameraSelector cameraSelector = new CameraSelector.Builder().requireLensFacing(
            CameraSelector.LENS_FACING_BACK)
        .build();

    preview.setSurfaceProvider(surfaceProvider);

    imageAnalysis = new ImageAnalysis.Builder()
        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
        .setTargetAspectRatio(AspectRatio.RATIO_16_9)
        .build();

    imageAnalysis.setAnalyzer(executor,
        new BarcodeAnalyzer(settings, this::finishWithSuccess, cameraOverlay));

    camera = cameraProvider.bindToLifecycle(this, cameraSelector, imageAnalysis, preview);
  }
}
